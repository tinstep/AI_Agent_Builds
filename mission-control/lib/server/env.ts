function getRequiredEnv(name: string) {
  const value = process.env[name];

  if (!value) {
    throw new Error(`Missing required environment variable: ${name}`);
  }

  return value;
}

export function getDatabaseUrl() {
  return getRequiredEnv("DATABASE_URL");
}

export function getEncryptionKey() {
  const key = getRequiredEnv("APP_ENCRYPTION_KEY");

  if (key.length !== 32) {
    throw new Error("APP_ENCRYPTION_KEY must be exactly 32 characters for the initial crypto implementation.");
  }

  return key;
}
