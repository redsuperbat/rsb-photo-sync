import { AccessOptions, Client } from "basic-ftp";
import { URL } from "node:url";

const parseUri = (uri?: string): AccessOptions => {
  if (!uri) {
    console.error("ftp uri is mandatory");
    process.exit(1);
  }
  const url = new URL(uri);
  return {
    host: url.host,
    password: url.password,
    port: url.port ? parseInt(url.port) : undefined,
    secure: false,
    user: url.username,
  };
};

const client = new Client();
await client.access(parseUri(process.env.FTP_URI));
const uploadFromDir = process.env.UPLOAD_FROM_DIR ?? "./photos";

const today = new Date();
const remoteDir = `photoprism-${today.getFullYear()}-${today.getMonth()}-${today.getDay()}`;
const time = Date.now();
console.info("syncing", uploadFromDir, "to", remoteDir);
await client.uploadFromDir(uploadFromDir, remoteDir);
client.close();
console.info("sync complete");
console.info("time ms", Date.now() - time);
