import json
import base64
import time
import jwt.algorithms
import rsa
import urllib.request
import jwt  # PyJWT
from urllib.parse import quote
# from jwt.algorithms import RSAAlgorithm

# CONFIGURABLE VALUES
CLOUDFRONT_URL_BASE = "https://cdn.ourjourneys.lukecreated.com"
CLOUDFRONT_KEY_PAIR_ID = "K1MRL445QVRPJP"
CLOUDFRONT_PRIVATE_KEY_PATH = "private_key.pem"  # Use /tmp/ or mount via layer
SIGNED_URL_EXPIRATION = 300  # seconds (5 minutes)
FIREBASE_PROJECT_ID = "surprise-xiaokeai"

# Google's Firebase public keys endpoint
GOOGLE_CERTS_URL = "https://www.googleapis.com/robot/v1/metadata/x509/securetoken@system.gserviceaccount.com"


def lambda_handler(event, context):
    try:
        headers = event.get("headers") or {}
        auth_header = headers.get("Authorization", "")
        if not auth_header.startswith("Bearer "):
            return _response(401, {"message": "Missing or malformed token"})

        id_token = auth_header.split("Bearer ")[1]
        decoded_token = verify_firebase_token(id_token)
        user_id = decoded_token.get("user_id")

        # Get object_key from body
        body = event.get("body")
        if body is None:
            return _response(400, {"message": "Missing request body"})

        body_json = json.loads(body)
        object_key = body_json.get("object_key")
        if not object_key:
            return _response(400, {"message": "Missing 'object_key'"})

        signed_url = generate_signed_url(f"{CLOUDFRONT_URL_BASE}/{object_key}")
        return _response(200, {"signed_url": signed_url})

    except Exception as e:
        return _response(500, {"message": f"Error: {str(e)}"})

# ----------------------------------
# 🔐 FIREBASE JWT VERIFICATION
# ----------------------------------


def verify_firebase_token(id_token):
    # Step 1: Fetch public keys from Google
    certs = json.loads(urllib.request.urlopen(GOOGLE_CERTS_URL).read())

    # Step 2: Decode token header to get key ID (kid)
    unverified_header = jwt.get_unverified_header(id_token)
    kid = unverified_header["kid"]

    # Step 3: Load correct public key
    cert_str = certs[kid]
    public_key = jwt.algorithms.RSAAlgorithm.from_jwk(json.dumps(
        jwt.algorithms.RSAAlgorithm.pem_to_jwk(cert_str)))

    # Step 4: Decode & validate token
    decoded_token = jwt.decode(
        id_token,
        public_key,
        algorithms=["RS256"],
        audience=FIREBASE_PROJECT_ID,
        issuer=f"https://securetoken.google.com/{FIREBASE_PROJECT_ID}"
    )
    return decoded_token

# ----------------------------------
# 🔐 CLOUDFRONT SIGNED URL GENERATOR
# ----------------------------------


def generate_signed_url(url):
    expire_time = int(time.time()) + SIGNED_URL_EXPIRATION
    policy = {
        "Statement": [{
            "Resource": url,
            "Condition": {
                "DateLessThan": {"AWS:EpochTime": expire_time}
            }
        }]
    }

    policy_json = json.dumps(policy).replace(" ", "")
    signature = sign_policy(policy_json)

    # Encode signature for CloudFront
    encoded_sig = base64.b64encode(signature).decode('utf-8')
    encoded_sig = encoded_sig.replace(
        '+', '-').replace('=', '_').replace('/', '~')

    encoded_policy = base64.b64encode(
        policy_json.encode('utf-8')).decode('utf-8')
    encoded_policy = encoded_policy.replace(
        '+', '-').replace('=', '_').replace('/', '~')

    return (
        f"{url}?Policy={quote(encoded_policy)}"
        f"&Signature={quote(encoded_sig)}"
        f"&Key-Pair-Id={CLOUDFRONT_KEY_PAIR_ID}"
    )


def sign_policy(policy):
    with open(CLOUDFRONT_PRIVATE_KEY_PATH, "rb") as f:
        private_key = rsa.PrivateKey.load_pkcs1(f.read())
    return rsa.sign(policy.encode("utf-8"), private_key, "SHA-1")

# ----------------------------------
# 📦 Helper: API Gateway Response
# ----------------------------------


def _response(status, body):
    return {
        "statusCode": status,
        "headers": {"Content-Type": "application/json"},
        "body": json.dumps(body if isinstance(body, dict) else {"message": body})
    }
