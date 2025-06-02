""" test runner for thumb gen lambda functions """

from verify_mock import verify_handler
from auth_mock import get_mock_authorizer
from flex_thumbnail_gen import lambda_handler as flex_thumb_gen
import json
import os
import ssl

# Create a custom SSL context for local testing only
ssl._create_default_https_context = ssl._create_unverified_context


# Set env variables for testing

TOKEN = os.environ['REAL_TOKEN'] = "valid-token"


def test_verify_valid_token():
    event = {
        "headers": {
            "authorization": "Bearer valid-token"
        }
    }
    result = verify_handler(event)
    print("VERIFY (valid):", json.dumps(result, indent=2))


def test_verify_invalid_token():
    event = {
        "headers": {
            "authorization": "Bearer invalid-token"
        }
    }
    result = verify_handler(event)
    print("VERIFY (invalid):", json.dumps(result, indent=2))


def test_flex_thumb_gen():
    event = get_mock_authorizer()
    event["body"] = json.dumps({

        "inputImage": "<base64 encoded image data>",
        "inputImageName": "TunghaiStudentCardPhotoUpper@0.5x.png",
        "inputEncoding": "base64",
        "inputImageDataType": "base64",
        "outputConfigs": {
            "outputImageDataType": "base64",
            "outputImageFileExtension": "webp",
            "outputImageName": "sample_thumbnail.webp",
            "imageQuality": 80.0,
            "maxFileSize": 300,
            "maxFileSizeUnit": "KB",
            "width": 480,
            "height": 320,
            "preserveAspectRatio": True

        }
    })
    result = flex_thumb_gen(event, None)
    print("FLEX THUMB GEN RESULT:", json.dumps(result, indent=2))


if __name__ == "__main__":
    test_flex_thumb_gen()
