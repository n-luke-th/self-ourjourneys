import json
import os
import boto3


def handler(event, context):
    uid = event["requestContext"]["authorizer"]["uid"]
    body = json.loads(event["body"])
    filenames = body["filenames"]  # Accept single or multiple
    folder = body.get("folder", "")

    s3 = boto3.client("s3",
                      aws_access_key_id=os.environ["R2_ACCESS_KEY"],
                      aws_secret_access_key=os.environ["R2_SECRET_KEY"],
                      endpoint_url=os.environ["R2_ENDPOINT"])

    result = []
    for filename in filenames:
        key = f"{uid}/{folder}/{filename}".strip("/")
        url = s3.generate_presigned_url(
            "get_object",
            Params={"Bucket": os.environ["R2_BUCKET_NAME"], "Key": key},
            ExpiresIn=600
        )
        result.append({"filename": filename, "url": url, "key": key})

    return {
        "statusCode": 200,
        "body": json.dumps(result)
    }
