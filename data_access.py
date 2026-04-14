# data_access.py - Core Database Access Module

import sqlite3
from datetime import datetime
from typing import Optional, Dict, Any

# --- Configuration ---
DATABASE_NAME = "data.db"

# --- DB Connection Helper ---
def get_db_connection():
    """Establishes and returns a connection to the SQLite database."""
    conn = sqlite3.connect(DATABASE_NAME)
    conn.row_factory = sqlite3.Row  # Allows accessing columns by name
    return conn

# --- PHASE 1: Data Access Functions ---

# --- FX Rates ---
def save_fx_rate(from_curr: str, to_curr: str, rate: float, timestamp: datetime) -> bool:
    """Saves a new FX rate entry. Prevents overwriting if record exists for the same time slice."""
    try:
        conn = get_db_connection()
        cursor = conn.cursor()
        # Use INSERT OR REPLACE for simplicity in MVP simulation
        cursor.execute("""
            INSERT OR REPLACE INTO fx_rates 
            (from_currency, to_currency, rate, timestamp) 
            VALUES (?, ?, ?, ?)
        """, (from_curr, to_curr, rate, timestamp))
        conn.commit()
        print(f"[DB] Successfully saved FX rate: {from_curr}/{to_curr} = {rate}")
        return True
    except sqlite3.Error as e:
        print(f"[DB ERROR] Failed to save FX rate: {e}")
        return False
    finally:
        get_db_connection().close()

def fetch_latest_rates(from_curr: str, to_curr: str) -> Optional[Dict[str, Any]]:
    """Fetches the most recent FX rate record."""
    try:
        conn = get_db_connection()
        cursor = conn.cursor()
        cursor.execute("""
            SELECT from_currency, to_currency, rate, timestamp FROM fx_rates
            WHERE from_currency = ? AND to_currency = ?
            ORDER BY timestamp DESC LIMIT 1
        """, (from_curr, to_curr))
        row = cursor.fetchone()
        conn.close()
        if row:
            return dict(row)
        return None
    except sqlite3.Error as e:
        print(f"[DB ERROR] Failed to fetch FX rates: {e}")
        return None
    finally:
        if 'conn' not in locals():
            get_db_connection().close() # Ensure closure if error happens before assignment

# --- Generic Metrics ---
def save_generic_metric(metric_name: str, value: float, timestamp: datetime, source: str) -> bool:
    """Saves a general economic metric."""
    try:
        conn = get_db_connection()
        cursor = conn.cursor()
        cursor.execute("""
            INSERT OR REPLACE INTO metrics 
            (metric_name, value, timestamp, source) 
            VALUES (?, ?, ?, ?)
        """, (metric_name, value, timestamp, source))
        conn.commit()
        print(f"[DB] Successfully saved metric: {metric_name} = {value}")
        return True
    except sqlite3.Error as e:
        print(f"[DB ERROR] Failed to save metric: {e}")
        return False
    finally:
        get_db_connection().close()

def fetch_latest_metric(metric_name: str) -> Optional[Dict[str, Any]]:
    """Fetches the most recent metric record."""
    try:
        conn = get_db_connection()
        cursor = conn.cursor()
        cursor.execute("""
            SELECT metric_name, value, timestamp, source FROM metrics
            WHERE metric_name = ?
            ORDER BY timestamp DESC LIMIT 1
        """, (metric_name,))
        row = cursor.fetchone()
        conn.close()
        if row:
            return dict(row)
        return None
    except sqlite3.Error as e:
        print(f"[DB ERROR] Failed to fetch metric: {e}")
        return None
    finally:
        get_db_connection().close()

# --- User Management (For Phase 2) ---
# NOTE: Password hashing logic is deferred to Phase 2 but function signatures are here.

def initialize_user_table(conn):
    """Creates the users table if it doesn't exist."""
    cursor = conn.cursor()
    cursor.execute("""
        CREATE TABLE IF NOT EXISTS users (
            user_id INTEGER PRIMARY KEY AUTOINCREMENT,
            username TEXT UNIQUE NOT NULL,
            password_hash TEXT NOT NULL,
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
        )
    """)
    conn.commit()

def initialize_subscription_table(conn):
    """Creates the subscriptions table if it doesn't exist."""
    cursor = conn.cursor()
    cursor.execute("""
        CREATE TABLE IF NOT EXISTS subscriptions (
            subscription_id INTEGER PRIMARY KEY AUTOINCREMENT,
            user_id INTEGER NOT NULL,
            plan_type TEXT NOT NULL,
            max_requests_per_day INTEGER NOT NULL,
            is_active BOOLEAN DEFAULT TRUE,
            FOREIGN KEY (user_id) REFERENCES users(user_id)
        )
    """)
    conn.commit()

# --- MAIN CONNECTION TEST ---
if __name__ == "__main__":
    print("--- Running data_access.py self-test ---")
    # This block runs when the file is executed directly
    pass # Placeholder for direct execution test

