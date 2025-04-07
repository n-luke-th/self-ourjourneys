import jwt from "jsonwebtoken";
import https from "https";

let publicKeys;

const getFirebasePublicKeys = () => {
  return new Promise((resolve, reject) => {
    if (publicKeys) return resolve(publicKeys);
    https
      .get(
        "https://www.googleapis.com/robot/v1/metadata/x509/securetoken@system.gserviceaccount.com",
        (res) => {
          let data = "";
          res.on("data", (chunk) => (data += chunk));
          res.on("end", () => {
            publicKeys = JSON.parse(data);
            resolve(publicKeys);
          });
        }
      )
      .on("error", reject);
  });
};

export const handler = async (event, context, callback) => {
  const request = event.Records[0].cf.request;
  const headers = request.headers;

  const authHeader = headers["authorization"]?.[0]?.value;
  if (!authHeader || !authHeader.startsWith("Bearer ")) {
    return callback(null, {
      status: "403",
      statusDescription: "Forbidden: Missing or invalid token",
    });
  }

  const token = authHeader.split(" ")[1];

  try {
    const keys = await getFirebasePublicKeys();
    const decodedHeader = jwt.decode(token, { complete: true });

    if (!decodedHeader || !decodedHeader.header || !decodedHeader.header.kid) {
      throw new Error("Invalid token header");
    }

    const kid = decodedHeader?.header.kid;
    const publicKey = keys[kid ?? ""];

    const decodedToken = jwt.verify(token, publicKey, {
      algorithms: ["RS256"],
      audience: "surprise-xiaokeai",
      issuer: "https://securetoken.google.com/surprise-xiaokeai",
    });

    return callback(null, request);
  } catch (err) {
    console.error("JWT validation failed:", err);
    return callback(null, {
      status: "403",
      statusDescription: "Forbidden: Token verification failed",
    });
  }
};
