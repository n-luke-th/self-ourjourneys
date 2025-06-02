""" flex thumbnail generator lambda function """
import base64
import json
import io
import os
from PIL import Image, UnidentifiedImageError
import imghdr
from typing import Dict, Any, Optional, Tuple

# HEIC support
try:
    import pillow_heif
    pillow_heif.register_heif_opener()
    HEIF_SUPPORTED = True
except ImportError:
    HEIF_SUPPORTED = False

SUPPORTED_FORMATS = {"jpeg", "jpg", "png", "webp",
                     "gif", "heic" if HEIF_SUPPORTED else None}
UNSUPPORTED_FORMATS = {"svg"}
DEFAULT_MAX_WIDTH = 1920
DEFAULT_MAX_HEIGHT = 1080


def lambda_handler(event, context):
    try:
        body = json.loads(event.get("body", "{}"))
        input_data = body.get("inputImage")
        input_data_type = body.get("inputImageDataType", "base64")
        input_encoding = body.get("inputEncoding", "base64")
        input_image_name = body.get("inputImageName", "image")
        output_configs = body.get("outputConfigs", {})

        preserve_aspect_ratio = output_configs.get("preserveAspectRatio", True)
        output_image_data_type = output_configs.get(
            "outputImageDataType", "base64")
        output_file_ext = output_configs.get(
            "outputImageFileExtension", "webp").lower()
        output_image_name = output_configs.get(
            "outputImageName", f"thumbnail.{output_file_ext}")
        image_quality = int(output_configs.get("imageQuality", 70))
        max_file_size = output_configs.get("maxFileSize", 512)
        max_file_size_unit = output_configs.get("maxFileSizeUnit", "KB")
        resize_width = output_configs.get("width", DEFAULT_MAX_WIDTH)
        resize_height = output_configs.get("height", DEFAULT_MAX_HEIGHT)

        image_bytes = _decode_input_data(input_data, input_data_type)
        if image_bytes is None:
            return _response(400, False, error="Unsupported inputImageDataType or corrupted data.")

        detected_ext = _detect_extension(image_bytes, input_image_name)
        if detected_ext not in SUPPORTED_FORMATS:
            return _response(415, False, error=f"'{detected_ext}' format is not supported for thumbnail generation.")

        mime_type = f"image/{detected_ext}" if detected_ext != "jpg" else "image/jpeg"
        size_value, size_unit = _format_file_size(len(image_bytes))
        input_metadata = {
            "inputImageName": input_image_name,
            "detectedInputImageSize": size_value,
            "detectedInputImageSizeUnit": size_unit,
            "detectedInputFileExtension": detected_ext,
            "detectedInputMimeType": mime_type
        }

        img = _load_image(image_bytes, detected_ext)
        if img is None:
            return _response(400, False, input_metadata, error="Failed to decode the image.")

        if preserve_aspect_ratio:
            img.thumbnail((resize_width, resize_height))
        else:
            img = img.resize((resize_width, resize_height))

        quality = image_quality
        output_bytes = _compress_image(img, output_file_ext, quality)

        if max_file_size:
            max_bytes = _convert_size_to_bytes(
                max_file_size, max_file_size_unit)
            while len(output_bytes) > max_bytes and quality > 10:
                quality -= 5
                output_bytes = _compress_image(img, output_file_ext, quality)

        output_encoding, encoded_output = _encode_output_data(
            output_bytes, output_image_data_type)

        out_size_value, out_size_unit = _format_file_size(len(output_bytes))
        output_data = {
            "outputImage": encoded_output,
            "outputImageDataType": output_image_data_type,
            "outputImageFileExtension": output_file_ext,
            "outputImageName": output_image_name,
            "imageQuality": quality,
            "fileSize": out_size_value,
            "fileSizeUnit": out_size_unit,
            "width": img.width,
            "height": img.height,
            "outputEncoding": output_encoding
        }

        return _response(200, True, input_metadata, output_data=output_data)

    except UnidentifiedImageError:
        return _response(400, False, error="Could not identify image file.")
    except Exception as e:
        return _response(500, False, error=f"Internal server error: {str(e)}")


# ----------------- Utilities -------------------

def _decode_input_data(data, data_type: str) -> Optional[bytes]:
    try:
        if data_type == "base64":
            return base64.b64decode(data)
        elif data_type in ["bytes", "Uint8List"]:
            return bytes(data)
        return None
    except Exception:
        return None


def _detect_extension(image_bytes: bytes, fallback_name: str) -> str:
    fmt = imghdr.what(None, image_bytes)
    if fmt:
        if fmt == "jpeg":
            return "jpg"
        return fmt
    ext = os.path.splitext(fallback_name)[-1].lower().replace(".", "")
    return ext if ext in SUPPORTED_FORMATS else "jpg"


def _load_image(image_bytes: bytes, ext: str) -> Optional[Image.Image]:
    try:
        image = Image.open(io.BytesIO(image_bytes))
        if ext == "gif":
            image.seek(0)
        if image.mode in ("RGBA", "P"):
            image = image.convert("RGB")
        return image
    except Exception:
        return None


def _compress_image(image: Image.Image, fmt: str, quality: int) -> bytes:
    buffer = io.BytesIO()
    save_format = "JPEG" if fmt == "jpg" else fmt.upper()
    image.save(buffer, format=save_format, quality=quality)
    return buffer.getvalue()


def _encode_output_data(image_bytes: bytes, output_type: str) -> Tuple[str, Any]:
    if output_type == "base64":
        return "base64", base64.b64encode(image_bytes).decode("utf-8")
    return "byte_array", list(image_bytes)


def _format_file_size(num_bytes: int) -> Tuple[float, str]:
    if num_bytes < 1024:
        return num_bytes, "B"
    elif num_bytes < 1024 * 1024:
        return round(num_bytes / 1024, 2), "KB"
    return round(num_bytes / (1024 * 1024), 2), "MB"


def _convert_size_to_bytes(size: int, unit: str) -> int:
    unit = unit.upper()
    if unit == "B":
        return size
    elif unit == "KB":
        return size * 1024
    elif unit == "MB":
        return size * 1024 * 1024
    return size


def _response(status_code: int, is_generated: bool, input_metadata: dict | None = None, output_data: dict | None = None, error: str | None = None):
    payload = {
        "isGenerated": is_generated,
        "inputMetadata": input_metadata or {},
        "outputData": output_data if is_generated else None
    }
    if error != None:
        payload["errorMessage"] = f"error: {error}"
    return {
        "statusCode": status_code,
        "headers": {"Content-Type": "application/json"},
        "body": json.dumps(payload)
    }
