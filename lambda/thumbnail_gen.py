""" auto thumbnail generator lambda function """

# import datetime
import uuid
from urllib.parse import unquote_plus
from PIL import Image, UnidentifiedImageError
from s3configs import s3, S3_BUCKET_NAME, S3_BUCKET_NAME_2

# HEIC support
try:
    import pillow_heif
    pillow_heif.register_heif_opener()
    HEIF_SUPPORTED = True
except ImportError:
    HEIF_SUPPORTED = False

SUPPORTED_FORMATS = {"jpeg", "jpg", "png", "webp",
                     "gif", "heic" if HEIF_SUPPORTED else None}


def resize_image(image_path, resized_path):
    try:
        with Image.open(image_path) as image:
            image.thumbnail(tuple(x / 2 for x in image.size))
            image.save(resized_path)
    except UnidentifiedImageError:
        print("Could not identify image file.")
    except Exception as e:
        print(f"Error resizing image: {str(e)}")


def lambda_handler(event, context):
    for record in event['Records']:
        # decode the object key
        original_obj_key = unquote_plus(record['s3']['object']['key'])
        file_name = original_obj_key.split('/')[-1]
        tmpkey = original_obj_key.replace('/', '')
        # date_time = datetime.datetime.now(
        #     datetime.timezone.utc).strftime("%Y%m%dT%H%M%S")
        # ephemeral storage path of the lambda function to store the downloaded file
        download_path = '/tmp/{}{}'.format(uuid.uuid4(), tmpkey)
        # ephemeral storage path of the lambda function to store the resized file
        upload_path = '/tmp/resized-{}'.format(tmpkey)
        # get the original image from s3 bucket
        s3.download_file(S3_BUCKET_NAME, original_obj_key, download_path)
        resize_image(download_path, upload_path)
        # upload the resized image to s3 bucket
        s3.upload_file(upload_path, S3_BUCKET_NAME_2,
                       'gen/thumbs/{}'.format(original_obj_key))
