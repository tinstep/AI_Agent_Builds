# db_setup.py - Database Initialization Script

import sqlite3
from data_access import (
    initialize_user_table, 
    initialize_subscription_table, 
    get_db_connection
)
from auth_service import get_hashed_password
from datetime import datetime

def setup_database():
    """
    Initializes the SQLite database by creating all necessary tables
    and populating initial administrative data if required.
    """
    print("--- Starting Database Setup ---")
    conn = get_db_connection()
    
    try:
        # Phase 1: Create Core Tables
        print("-> Running Phase 1: Schema Creation...")
        initialize_user_table(conn)
        initialize_subscription_table(conn)
        
        # Optional: Insert a default admin user/subscription for initial testing
        # WARNING: This uses hardcoded credentials and should be replaced by Phase 2 logic.
        print("-> Inserting mock admin user (password hashed with bcrypt)...")
        try:
            cursor = conn.cursor()
            test_password = "admin123"
            hashed_pw = get_hashed_password(test_password)
            # Use REPLACE to insert new or update existing mock admin user
            cursor.execute("""
                INSERT OR REPLACE INTO users (user_id, username, password_hash) 
                VALUES (1, 'admin', ?)
            """, (hashed_pw,))
            
            # Mocking a default subscription for the admin user
            cursor.execute("""
                INSERT OR IGNORE INTO subscriptions (subscription_id, user_id, plan_type, max_requests_per_day) 
                VALUES (1, 1, 'free', 100)
            """)
            conn.commit()
            print("   [SUCCESS] Mock admin user (id=1) and free subscription created.")

        except sqlite3.Error as e:
            print(f"   [WARNING] Could not insert mock admin user. Manual setup needed: {e}")
            
        print("✅ Database initialization complete. Schema is ready.")
    
    except sqlite3.Error as e:
        print(f"❌ FATAL DATABASE ERROR during setup: {e}")
    finally:
        conn.close()

if __name__ == "__main__":
    setup_database()

