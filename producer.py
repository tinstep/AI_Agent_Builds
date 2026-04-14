# producer.py - Simplified Data Ingestion Simulator

import time
import random
from datetime import datetime, timedelta
from data_access import save_fx_rate, save_generic_metric
from auth_service import get_db_connection

def setup_database_for_producer():
    """Creates tables if they don't exist."""
    conn = get_db_connection()
    try:
        cur = conn.cursor()
        cur.execute("""
            CREATE TABLE IF NOT EXISTS fx_rates (
                from_currency TEXT,
                to_currency TEXT,
                rate REAL,
                timestamp TIMESTAMP
            )
        """)
        cur.execute("""
            CREATE TABLE IF NOT EXISTS metrics (
                metric_name TEXT,
                value REAL,
                timestamp TIMESTAMP,
                source TEXT
            )
        """)
        conn.commit()
        print("✅ Producer: Database ready.")
    finally:
        conn.close()

def run_producer_cycle():
    print("\n=====================================================================")
    print("🚀 STARTING DATA PRODUCER CYCLE")
    print("=====================================================================")
    setup_database_for_producer()

    for i in range(10):
        # Generate realistic fluctuation around 0.92
        rate = round(0.92 + random.uniform(-0.005, 0.005), 4)

        # Fixed currency pair: USD -> EUR
        from_curr = "USD"
        to_curr = "EUR"

        # Generate housing metric
        housing = round(random.uniform(250.0, 300.0), 2)

        # Timestamp
        ts = datetime.now()

        # Save to DB
        save_fx_rate(from_curr, to_curr, rate, ts)
        save_generic_metric("housing_index", housing, ts, "simulator")

        print(f"[CYCLE {i+1}/10] Saved: {from_curr}/{to_curr} = {rate}, housing = {housing}")
        time.sleep(2)

    print("\n✅ Producer finished: 10 cycles complete.\n")

if __name__ == "__main__":
    run_producer_cycle()
