import os
import boto3

TESTING = True

if TESTING:
    from decouple import config
    S3_BUCKET_NAME = config("S3_BUCKET_NAME", default="your-bucket-name")
else:
    S3_BUCKET_NAME = os.environ["S3_BUCKET_NAME"]


s3 = boto3.client("s3")
