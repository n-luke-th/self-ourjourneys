import firebase_admin
from firebase_admin import credentials, auth

# Initialize Firebase Admin SDK
cred = credentials.Certificate("serviceAccountKey.json")
firebase_admin.initialize_app(cred)


def verify_handler(event, context):
    token = event.get("headers", {}).get("authorization", "")
    if token.startswith("Bearer "):
        token = token[len("Bearer "):]
    # print("TOKEN:", token)
    if not token:
        return {"isAuthorized": False}

    try:
        decoded_token = auth.verify_id_token(token)
        uid = decoded_token["uid"]
        email = decoded_token.get("email")
        return {
            "isAuthorized": True,
            "context": {
                "uid": uid,
                "email": email or ""
            }
        }
    except Exception as e:
        print("Error verifying token:", e)
        return {"isAuthorized": False}
