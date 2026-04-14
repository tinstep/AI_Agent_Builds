# auth_service.py - Authentication and Authorization Module

import sqlite3
import jwt
import datetime
from passlib.context import CryptContext
from data_access import get_db_connection
from typing import Optional, Dict, Any, Tuple

# --- Configuration ---
JWT_SECRET = "SUPER_SECRET_KEY_CHANGE_ME_IN_PRODUCTION" # MUST BE CHANGED
JWT_ALGORITHM = "HS256"
ACCESS_TOKEN_EXPIRE_HOURS = 1 # Tokens expire in 1 hour

# --- Security Primitives ---
# Using passlib with sha256_crypt for stable, secure password hashing
pwd_context = CryptContext(schemes=["sha256_crypt"], deprecated="auto")

def verify_password(plain_password: str, hashed_password: str) -> bool:
    """Verifies a plaintext password against a stored hash."""
    try:
        return pwd_context.verify(plain_password, hashed_password)
    except Exception as e:
        print(f"[AUTH ERROR] Password verification failed: {e}")
        return False

def get_hashed_password(plain_password: str) -> str:
    """Generates a secure hash for a new password."""
    return pwd_context.hash(plain_password)

# --- Authentication Logic ---

def create_jwt_token(user_id: int, username: str, plan_type: str, expiry_minutes: int = ACCESS_TOKEN_EXPIRE_HOURS * 60) -> str:
    """Creates a signed JWT token containing user context."""
    try:
        to_encode = {
            "user_id": user_id,
            "username": username,
            "plan_type": plan_type,
            "exp": datetime.datetime.utcnow() + datetime.timedelta(minutes=expiry_minutes)
        }
        token = jwt.encode(to_encode, JWT_SECRET, algorithm=JWT_ALGORITHM)
        return token
    except Exception as e:
        print(f"[AUTH ERROR] Failed to create JWT: {e}")
        return ""

def login_user(username: str, password: str) -> Optional[str]:
    """
    Authenticates a user against the database and returns a JWT upon success.
    This function simulates the primary login flow.
    """
    conn = get_db_connection()
    try:
        cursor = conn.cursor()
        # Fetch user record first
        cursor.execute("SELECT user_id, username, password_hash FROM users WHERE username = ?", (username,))
        user_row = cursor.fetchone()
        
        if not user_row:
            print(f"[AUTH] User {username} not found.")
            return None
            
        user_id = user_row['user_id']
        hashed_password = user_row['password_hash']

        # Verify password
        if verify_password(password, hashed_password):
            # Fetch subscription details (Assuming user 1 is always valid for MVP)
            cursor.execute("""
                SELECT plan_type, max_requests_per_day FROM subscriptions 
                WHERE user_id = ? 
                ORDER BY subscription_id DESC LIMIT 1
            """, (user_id,))
            sub_row = cursor.fetchone()
            
            if not sub_row:
                 print("[AUTH] User found but no active subscription found. Treating as temporary access.")
                 plan_type = "none"
                 max_requests = 1
            else:
                plan_type = sub_row['plan_type']
                max_requests = sub_row['max_requests_per_day']

            # Generate and return the token
            token = create_jwt_token(user_id, username, plan_type)
            print(f"[AUTH SUCCESS] Token generated for {username} with plan {plan_type}.")
            return token
        else:
            print("[AUTH] Invalid password provided.")
            return None
    finally:
        conn.close()

# --- Dependency: Middleware Function (to be used in FastAPI/Flask) ---

def get_current_user_context(token: str) -> Optional[Dict[str, Any]]:
    """
    Decodes and validates the JWT token. Returns user context or None if invalid.
    This function mimics the middleware dependency.
    """
    try:
        payload = jwt.decode(token, JWT_SECRET, algorithms=[JWT_ALGORITHM])
        # This context object will be attached to the request object in FastAPI/Flask
        return {
            "user_id": payload['user_id'],
            "username": payload['username'],
            "plan_type": payload['plan_type'],
            "expiry_date": payload['exp']
        }
    except jwt.ExpiredSignatureError:
        print("[AUTH] Token has expired.")
        return None
    except jwt.InvalidTokenError:
        print("[AUTH] Invalid token signature.")
        return None

# --- Usage Tracking (Placeholder for Phase 4 integration) ---
# A simple in-memory counter for MVP testing. This MUST be replaced by DB/Cache logic in production.
USAGE_COUNTER: Dict[str, int] = {}

def check_usage_limit(user_id: int, plan_type: str) -> bool:
    """Checks if the user has exceeded their usage quota for the day."""
    # In a real system, this would query a 'usage_logs' table.
    # For MVP, we'll just check against the plan's limit.
    if plan_type == "none":
        return False # No access if plan is 'none'
    
    # Placeholder: Assume all users have a fixed limit based on their plan type for the MVP.
    # A proper implementation would check current day's usage against the stored max_requests_per_day.
    # We will trust the subscription data fetched during login for this simulation.
    return True # Assume success for now, as actual tracking requires a separate database table/service.

