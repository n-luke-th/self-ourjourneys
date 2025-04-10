from r2configs import R2_BUCKET_NAME, s3
import json


def handler(event, context):
    try:
        # Get requestContext or empty dict if missing
        request_context = event.get('requestContext', {})
        # Get authorizer or empty dict if missing
        authorizer = request_context.get('authorizer', {})
        uid = authorizer.get('uid')  # Get uid or None if missing
        body = json.loads(event["body"])
        folder = body.get("folder", "")

        filenames = []
        if "fileName" in body:  # Single file upload
            filenames = [body["fileName"]]
        elif "fileNames" in body:  # Multiple file uploads
            filenames = body["fileNames"]
        else:
            return {
                "statusCode": 400,
                "headers": {"Content-Type": "application/json"},
                "body": json.dumps({"error": "Missing 'fileName' or 'fileNames'"})
            }

        results = []
        for filename in filenames:
            key = f"{folder}/{filename}".strip("/")
            url = s3.generate_presigned_url(
                "get_object",
                Params={"Bucket": R2_BUCKET_NAME,
                        "Key": key},
                ExpiresIn=600
            )
            results.append({
                "fileName": filename,
                "key": key,
                "url": url
            })

        returning_results = {"results": (results if len(results) > 1 else results[0]), "requestContext": {
            "authorizer": authorizer}}

        return {
            "statusCode": 200,
            "headers": {"Content-Type": "application/json"},
            "body": json.dumps(returning_results, indent=2)
        }
    except Exception as e:
        return {
            "statusCode": 500,
            "headers": {"Content-Type": "application/json"},
            "body": json.dumps({"error": str(e)})
        }
