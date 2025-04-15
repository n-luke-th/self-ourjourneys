/* verify Firebase token to restrict the api requests (not working, use the Python version) */

import jwt from "jsonwebtoken";

let cachedCerts = null;
let certsExpireAt = 0;

const PROJ_ID = "surprise-xiaokeai";
// @ts-ignore
const JWK_URL =
  "https://www.googleapis.com/service_accounts/v1/jwk/securetoken@system.gserviceaccount.com";
const CERTS_URL =
  "https://www.googleapis.com/robot/v1/metadata/x509/securetoken@system.gserviceaccount.com";
const ISSUER = `https://securetoken.google.com/${PROJ_ID}`;

export async function handler(event) {
  const headers = event.header || {};
  const authHeader = headers.authorization || headers.Authorization;

  if (!authHeader || !authHeader.startsWith("Bearer ")) {
    return unauthorized("Missing or invalid Authorization header");
  }

  const idToken = authHeader.split(" ")[1];

  try {
    const decodedHeader = jwt.decode(idToken, { complete: true });
    if (!decodedHeader || !decodedHeader.header.kid) {
      return unauthorized("Invalid token header");
    }

    const certs = await getCerts();
    const cert = certs[decodedHeader.header.kid];
    if (!cert) {
      return unauthorized("Certificate for token not found");
    }

    const decoded = jwt.verify(idToken, cert, {
      algorithms: ["RS256"],
      issuer: ISSUER,
      audience: PROJ_ID,
    });

    // ✅ Token is valid
    return {
      isAuthorized: true,
      context: {
        // @ts-ignore
        uid: decoded.uid || decoded.sub,
        // @ts-ignore
        email: decoded.email || "",
      },
    };
  } catch (err) {
    console.error("Auth error:", err);
    return unauthorized("Unauthorized");
  }
}

function unauthorized(message) {
  return {
    isAuthorized: false,
    context: { error: message },
  };
}

async function getCerts() {
  const now = Date.now();
  if (cachedCerts && certsExpireAt > now) {
    return cachedCerts;
  }

  const response = await fetch(CERTS_URL);
  if (!response.ok) {
    throw new Error(`Failed to fetch certs: ${response.statusText}`);
  }

  const cacheControl = response.headers.get("cache-control");
  const certsJson = await response.json();

  const maxAgeMatch = /max-age=(\d+)/.exec(cacheControl || "");
  const maxAge = maxAgeMatch ? parseInt(maxAgeMatch[1], 10) : 3600;
  certsExpireAt = now + maxAge * 1000;
  cachedCerts = certsJson;

  return certsJson;
}
