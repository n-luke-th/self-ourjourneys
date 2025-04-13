import jwt from "jsonwebtoken";

let certsCache = null;
let certsExpiry = null;

async function fetchCerts() {
  const res = await fetch(
    "https://www.googleapis.com/robot/v1/metadata/x509/securetoken@system.gserviceaccount.com"
  );

  if (!res.ok) throw new Error(`Failed to fetch certs: ${res.status}`);
  const cacheControl = res.headers.get("cache-control");
  if (!cacheControl) throw new Error("Missing cache-control header");
  const maxAge = parseInt(
    /max-age=(\d+)/.exec(cacheControl)?.[1] || "3600",
    10
  );
  certsExpiry = Date.now() + maxAge * 1000;

  certsCache = await res.json();
  return certsCache;
}

async function getCerts() {
  if (certsCache && certsExpiry && Date.now() < certsExpiry) return certsCache;
  return await fetchCerts();
}

async function verifyFirebaseToken(token, projectId) {
  const decodedHeader = jwt.decode(token, { complete: true });
  const kid = decodedHeader?.header?.kid;
  if (!kid) throw new Error("Missing kid in JWT header");

  const certs = await getCerts();
  const cert = certs[kid];
  if (!cert) throw new Error("Public cert not found for kid");

  return jwt.verify(token, cert, {
    algorithms: ["RS256"],
    issuer: `https://securetoken.google.com/${projectId}`,
    audience: projectId,
  });
}

function unauthorized(message) {
  return {
    status: "401",
    statusDescription: "Unauthorized",
    body: JSON.stringify({ error: message }),
    headers: {
      "content-type": [{ key: "Content-Type", value: "application/json" }],
      "www-authenticate": [{ key: "WWW-Authenticate", value: "Bearer" }],
    },
  };
}

export const handler = async (event) => {
  const request = event.Records[0].cf.request;
  const headers = request.headers;
  const authHeader = headers.authorization?.[0]?.value;

  if (!authHeader?.startsWith("Bearer ")) {
    return unauthorized("Missing or malformed Authorization header");
  }

  const token = authHeader.slice(7);
  const projectId = "surprise-xiaokeai";

  try {
    const decoded = await verifyFirebaseToken(token, projectId);

    //// Optional: inject Firebase UID/email into headers
    // request.headers["x-firebase-uid"] = [
    //   // @ts-ignore
    //   { key: "x-firebase-uid", value: decoded.user_id || decoded.sub },
    // ];
    // request.headers["x-firebase-email"] = [
    //   // @ts-ignore
    //   { key: "x-firebase-email", value: decoded.email || "" },
    // ];

    delete request.headers.authorization; // 🧹 Strip token before forwarding

    return request;
  } catch (err) {
    console.error("Token verification error:", err);
    return unauthorized(err.message);
  }
};
