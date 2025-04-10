import os
import json
import boto3

def handler(event, context):
    uid = event["requestContext"]["authorizer"]["uid"]
    body = json.loads(event["body"])
    folder = body.get("folder", "")
    folder = f"{uid}/{folder}".strip("/")

    s3 = boto3.client(
        "s3",
        aws_access_key_id=os.environ["R2_ACCESS_KEY"],
        aws_secret_access_key=os.environ["R2_SECRET_KEY"],
        endpoint_url=os.environ["R2_ENDPOINT"]
    )

    filenames = []
    if "filename" in body:  # Single file upload
        filenames = [body["filename"]]
    elif "filenames" in body:  # Multiple file uploads
        filenames = body["filenames"]
    else:
        return {
            "statusCode": 400,
            "body": json.dumps({"error": "Missing 'filename' or 'filenames'"})
        }

    results = []
    for filename in filenames:
        key = f"{folder}/{filename}".strip("/")
        url = s3.generate_presigned_url(
            "put_object",
            Params={"Bucket": os.environ["R2_BUCKET_NAME"], "Key": key},
            ExpiresIn=600,
            HttpMethod="PUT"
        )
        results.append({
            "filename": filename,
            "url": url,
            "key": key
        })

    return {
        "statusCode": 200,
        "body": json.dumps(results if len(results) > 1 else results[0])
    }