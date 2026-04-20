import { createCipheriv, createDecipheriv, randomBytes } from "crypto";
import { getEncryptionKey } from "@/lib/server/env";

const IV_LENGTH = 16;

export function encryptSecret(value: string) {
  const iv = randomBytes(IV_LENGTH);
  const key = Buffer.from(getEncryptionKey(), "utf8");
  const cipher = createCipheriv("aes-256-cbc", key, iv);
  const encrypted = Buffer.concat([cipher.update(value, "utf8"), cipher.final()]);

  return `${iv.toString("hex")}:${encrypted.toString("hex")}`;
}

export function decryptSecret(payload: string) {
  const [ivHex, encryptedHex] = payload.split(":");

  if (!ivHex || !encryptedHex) {
    throw new Error("Invalid encrypted payload format.");
  }

  const iv = Buffer.from(ivHex, "hex");
  const encrypted = Buffer.from(encryptedHex, "hex");
  const key = Buffer.from(getEncryptionKey(), "utf8");
  const decipher = createDecipheriv("aes-256-cbc", key, iv);

  return Buffer.concat([decipher.update(encrypted), decipher.final()]).toString("utf8");
}
