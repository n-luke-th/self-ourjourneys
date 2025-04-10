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
        filenames = body["fileNames"]  # Accepts list
        folder = body.get("folder", "")

        result = []
        for filename in filenames:
            key = f"{folder}/{filename}".strip("/")
            s3.delete_object(Bucket=R2_BUCKET_NAME, Key=key)
            result.append({"deleted": key})

        returning_results = {"results": result, "requestContext": {
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
