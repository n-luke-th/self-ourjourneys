import os
from botocore.client import Config
import boto3

TESTING = True

if TESTING:
    from decouple import config
    R2_ACCESS_KEY = config("R2_ACCESS_KEY", default="your-access-key")
    R2_SECRET_KEY = config("R2_SECRET_KEY", default="your-secret-key")
    R2_BUCKET_NAME = config("R2_BUCKET_NAME", default="your-bucket-name")
    R2_ENDPOINT = config(
        "R2_ENDPOINT", default="https://your-account-id.r2.cloudflarestorage.com")
else:
    R2_ACCESS_KEY = os.environ["R2_ACCESS_KEY"]
    R2_SECRET_KEY = os.environ["R2_SECRET_KEY"]
    R2_BUCKET_NAME = os.environ["R2_BUCKET_NAME"]
    R2_ENDPOINT = os.environ["R2_ENDPOINT"]

REGION_NAME = "apac"
SIGNATURE_VERSION = "s3v4"


s3 = boto3.client("s3", config=Config(signature_version=SIGNATURE_VERSION),
                  aws_access_key_id=R2_ACCESS_KEY,
                  aws_secret_access_key=R2_SECRET_KEY,
                  endpoint_url=R2_ENDPOINT,
                  region_name=REGION_NAME)
