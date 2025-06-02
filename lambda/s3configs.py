import os
import boto3
from botocore.client import Config

TESTING = True

if TESTING:
    from decouple import config
    S3_BUCKET_NAME = config("S3_BUCKET_NAME", default="your-bucket-name")
    S3_BUCKET_NAME_2 = config("S3_BUCKET_NAME_2", default="your-bucket-name")
else:
    S3_BUCKET_NAME = os.environ["S3_BUCKET_NAME"]
    S3_BUCKET_NAME_2 = os.environ["S3_BUCKET_NAME_2"]

SIGNATURE_VERSION = "s3v4"

s3 = boto3.client("s3", config=Config(signature_version=SIGNATURE_VERSION))
