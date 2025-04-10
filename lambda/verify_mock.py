import os
import json

# MOCK decoder (for testing only)


def mock_verify_token(id_token):
    if id_token == "valid-token":
        return {
            "uid": "some-uid",
            "email": "some-email1234567@gmail.com"
        }
    raise Exception("Invalid token")


def verify_handler(event, context=None):
    token = event.get("headers", {}).get("authorization", "")
    if token.startswith("Bearer "):
        token = token.split("Bearer ")[1]

    try:
        decoded = mock_verify_token(token)
        return {
            "isAuthorized": True,
            "context": {
                "uid": decoded["uid"],
                "email": decoded["email"]
            }
        }
    except Exception as e:
        return {
            "isAuthorized": False,
            "context": {}
        }
