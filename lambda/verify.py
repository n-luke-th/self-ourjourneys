
# # from jwt import algorithms
# from jwt import PyJWKClient
# import jwt
# import os
# FIREBASE_PROJECT_ID = "surprise-xiaokeai"  # os.environ["FIREBASE_PROJECT_ID"]
# # # JWKS_URL = "https://www.googleapis.com/robot/v1/metadata/x509/securetoken@system.gserviceaccount.com"
# JWKS_URL = "https://www.googleapis.com/service_accounts/v1/jwk/securetoken@system.gserviceaccount.com"
# ISSUER = f"https://securetoken.google.com/{FIREBASE_PROJECT_ID}"
# AUDIENCE = FIREBASE_PROJECT_ID

# jwk_client = PyJWKClient(JWKS_URL)


# def verify_handler(event, context=None):
#     token = event.get("headers", {}).get("authorization", "")
#     if token.startswith("Bearer "):
#         token = token[len("Bearer "):]

#     try:
#         signing_key = jwk_client.get_signing_key_from_jwt(token)

#         decoded = jwt.decode(
#             token,
#             signing_key.key,
#             algorithms=["RS256"],
#             audience=AUDIENCE,
#             issuer=ISSUER,
#         )

#         return {
#             "isAuthorized": True,
#             "context": {
#                 "uid": decoded["user_id"],
#                 "email": decoded.get("email", "")
#             }
#         }

#     except Exception as e:
#         print("ERROR:", str(e))
#         return {
#             "isAuthorized": False,
#             "context": {}
#         }


import json
import firebase_admin
from firebase_admin import credentials, auth

# Initialize Firebase Admin SDK
cred = credentials.Certificate("serviceAccountKey.json")
firebase_admin.initialize_app(cred)


def lambda_handler(event, context):
    token = event.get("headers", {}).get("authorization", "")
    if not token:
        return {"isAuthorized": False}
    if token.startswith("Bearer "):
        token = token[len("Bearer "):]
    # print("TOKEN:", token)

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
