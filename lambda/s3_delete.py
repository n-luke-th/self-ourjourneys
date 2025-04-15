""" delete files from s3 bucket """

from s3configs import S3_BUCKET_NAME, s3
import json


def delete_handler(event, context):
    try:
        # Extract user context
        request_context = event.get('requestContext', {})
        authorizer = request_context.get('authorizer', {})
        uid = authorizer.get('uid')

        # Parse input
        body = json.loads(event["body"])
        filenames = body["fileNames"]  # Expecting a list
        folder = body.get("folder", "")

        # Prepare objects to delete
        objects_to_delete = [
            {"Key": f"{folder}/{filename}".strip("/")}
            for filename in filenames
        ]

        # Perform batch delete
        response = s3.delete_objects(
            Bucket=S3_BUCKET_NAME,
            Delete={"Objects": objects_to_delete}
        )

        returning_results = {
            "deleted": response.get("Deleted", []),
            "errors": response.get("Errors", []),
            "requestContext": {"authorizer": authorizer}
        }

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
