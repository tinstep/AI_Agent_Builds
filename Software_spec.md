# Software Specification Document: Economic Data Delivery MVP
**Project Goal:** To build a Minimum Viable Product (MVP) web application that allows commercial businesses to securely consume standardized economic data (FX rates, interest rates, housing metrics) via a REST API.

**Target Stack:**
*   **Backend Language:** Python (Python 3.10+)
*   **Database:** SQLite (for MVP, to minimize complexity)
*   **API Framework:** FastAPI (Recommended for modern, fast API development)
*   **Web Server:** Nginx (As a reverse proxy)
*   **Security:** JWT (JSON Web Tokens) for authentication.

---

## 🗺️ Project Phases & Deliverables

The project will be executed in 5 distinct, sequential phases. Each phase's completion is required before moving to the next, as dependencies exist between them.

### **Phase 1: Core Data Model & Persistence (The Foundation)**
**Goal:** Establish the stable data structure and basic read/write capability against an SQLite database.

**Specific Tasks:**
1.  **Schema Definition:** Define the required SQLite tables. Minimum required tables:
    *   `metrics`: Stores standardized time-series data (e.g., `metric_id`, `metric_name`, `value`, `timestamp`, `source`).
    *   `fx_rates`: Stores currency pair exchange rates (e.g., `from_currency`, `to_currency`, `rate`, `timestamp`).
    *   `users`: Stores user credentials (`user_id`, `username`, `password_hash`, `created_at`).
    *   `subscriptions`: Links users to their access levels/data allowances (`subscription_id`, `user_id`, `plan_type`, `is_active`, `max_requests_per_day`).
2.  **Database Initialization:** Create a Python utility script (`db_setup.py`) that connects to `data.db` and executes SQL statements to create all defined tables if they do not exist.
3.  **CRUD Module:** Develop a dedicated Python module (`data_access.py`) containing encapsulated functions for:
    *   `save_fx_rate(from_curr, to_curr, rate, timestamp)`
    *   `save_generic_metric(metric_name, value, timestamp, source)`
    *   `fetch_latest_rates(from_curr, to_curr)`
    *   `get_user_by_username(username)`

### **Phase 2: Authentication & Authorization (The Guard)**
**Goal:** Secure the application by implementing a robust, token-based authentication layer.

**Specific Tasks:**
1.  **Password Hashing:** Integrate a hashing library (e.g., `passlib` with Argon2 or bcrypt) into the user service.
2.  **JWT Implementation:** Implement token generation upon successful login (`login(username, password)` -> returns JWT).
3.  **Authorization Middleware:** Create a FastAPI/Flask *dependency* or middleware function that:
    *   Accepts the JWT from the `Authorization: Bearer <token>` header.
    *   Validates the token's signature, expiry, and issuer.
    *   Attaches the decoded user payload (e.g., `user_id`, `plan_type`) to the request object if valid.
4.  **Usage Tracking:** Integrate simple usage counting into the middleware to track requests against the user's `subscriptions` plan limit.

### **Phase 3: Data Producer (The Source)**
**Goal:** Write a standalone script to simulate the ingestion of data, testing the write path.

**Specific Tasks:**
1.  **Simulation Script (`producer.py`):** Create a script that simulates data inflow.
2.  **Scheduling Logic:** Implement a simple scheduler loop (e.g., run every 5 seconds) for development, simulating a background job.
3.  **Data Generation:** Generate synthetic, yet structured, data (e.g., FX rates that fluctuate slightly, metrics that change slightly).
4.  **Write Test:** Use the `data_access.py` functions from Phase 1 to commit this synthetic data to the `data.db`.

### **Phase 4: The Consumer API (The Endpoint)**
**Goal:** Build the read-only web service accessible via HTTP that enforces security and fetches data.

**Specific Tasks:**
1.  **Framework Setup:** Initialize the FastAPI application (`main.py`).
2.  **Endpoint:** Define a core read endpoint: `GET /api/v1/data/fx_rate`.
3.  **Security Enforcement:** **Crucial Step:** Apply the Phase 2 middleware to this endpoint. If authentication fails, respond immediately with an HTTP 401/403 error.
4.  **Data Retrieval:** If authorized, use the `data_access.py` functions to query SQLite, respecting the user's `plan_type` limits (e.g., premium users see more historical data than basic users).
5.  **Output:** Return clean, standardized JSON adhering to a defined schema.

### **Phase 5: Deployment Simulation & Finalization**
**Goal:** Wrap the services in a deployment simulation layer using Nginx.

**Specific Tasks:**
1.  **Nginx Config:** Create an Nginx configuration snippet (`nginx.conf`) to act as a reverse proxy:
    *   Direct all traffic to `http://localhost:8000/api/v1/...`
    *   Handle SSL termination (conceptual).
    *   Serve static files (like a potential simple dashboard frontend, if scope allows).
2.  **Execution Guide:** Write a comprehensive `README.md` detailing the startup sequence:
    1.  Run `python db_setup.py` (Initialization)
    2.  Run `python producer.py` (Starts in background)
    3.  Run `uvicorn main:app --host 127.0.0.1 --port 8000` (Starts API)
    4.  Test via `curl` or an HTTP client (testing Phase 2 & 4 together).

---
**Next Action:** I propose we begin with **Phase 1**. I will write the code for the schema definition and the basic SQLite connection utility.

Please confirm if this comprehensive specification meets your expectations for tracking our development process.