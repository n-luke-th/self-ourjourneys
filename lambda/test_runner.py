""" test runner for lambda functions """

from verify_mock import verify_handler
import json
import os
from auth_mock import get_mock_authorizer
from verify import verify_handler as real_verify_handler
# from verify import lambda_handler as real_verify_handler
from uploads import handler as upload_handler
from downloads import handler as download_handler
from deletes import handler as delete_handler
import ssl

# Create a custom SSL context for local testing only
ssl._create_default_https_context = ssl._create_unverified_context


# Set env variables for testing

TOKEN = os.environ['REAL_TOKEN'] = "valid-token"


def test_verify_real_token():
    event = {
        "headers": {
            "authorization": f"Bearer {TOKEN}"
        }
    }
    result = real_verify_handler(event, None)
    print("VERIFY (real):", json.dumps(result, indent=2))


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


def test_upload():
    event = get_mock_authorizer()
    event["body"] = json.dumps({
        "fileNames": ["test1.jpg", "test2.jpg"],
        "folder": "albums/test"
    })
    result = upload_handler(event, None)
    print("UPLOAD RESULT:", json.dumps(result, indent=2))


def test_download():
    event = get_mock_authorizer()
    event["body"] = json.dumps({
        "fileNames": ["test1.jpg", "test2.jpg"],
        "folder": "albums/test"
    })
    result = download_handler(event, None)
    print("DOWNLOAD RESULT:", json.dumps(result, indent=2))


def test_delete():
    event = get_mock_authorizer()
    event["body"] = json.dumps({
        "fileNames": ["test1.jpg", "test2.jpg"],
        "folder": "albums/test"
    })
    result = delete_handler(event, None)
    print("DELETE RESULT:", json.dumps(result, indent=2))


if __name__ == "__main__":
    # test_verify_real_token()
    # test_verify_valid_token()
    # test_verify_invalid_token()
    # test_upload()
    test_download()
    # test_delete()
