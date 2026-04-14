# README.md - Economic Data Platform MVP Deployment Guide

This document outlines the steps to run the entire Minimum Viable Product (MVP) using the current stack (SQLite, Python, FastAPI, Nginx).

**⚠️ IMPORTANT PREREQUISITES & SETUP:**
1.  **Libraries:** You must install all necessary Python packages in your environment:
    ```bash
    pip install fastapi uvicorn python-jose passlib[bcrypt] pyjwt sqlite3
    # Note: sqlite3 is usually standard library, but listing for completeness.
    ```
2.  **File Placement:** Ensure all following files are in the root of the workspace:
    *   `data_access.py`
    *   `auth_service.py`
    *   `db_setup.py`
    *   `producer.py`
    *   `main.py`
    *   (The final Nginx config will be placed in a separate folder for structure.)
3.  **Database:** The first run will create the `data.db` file.

---

## ⚙️ Execution Sequence (The Startup Workflow)

The system components must be brought online in this specific order:

### **STEP 1: Initialize the Database Schema (Phase 1)**
This runs SQL scripts to create the necessary tables in `data.db`.
```bash
python db_setup.py
# Expectation: [SUCCESS] Mock admin user (id=1) and free subscription created.
```

### **STEP 2: Start the Data Producer (Phase 3)**
This simulates the background service writing fluctuating data into the database periodically. It must run in the background (`&`).
```bash
python producer.py &
# Keep track of the PID/output to ensure it's running.
```
*(Wait for the producer to complete its 10 cycles and print "PRODUCER CYCLE FINISHED")*

### **STEP 3: Start the API Gateway Service (Phase 4)**
This starts the FastAPI server, making the data available via HTTP on port 8000. This process must run persistently.
```bash
uvicorn main:app --host 127.0.0.1 --port 8000 --reload
# NOTE: For production, replace 'uvicorn' with Gunicorn/Waitress running the app.
```

### **STEP 4: Test the End-to-End Flow (Manual Testing)**
**A. Get a Token (Login):** You must first authenticate to get a valid access token.
```bash
curl -X POST "http://localhost:8000/api/v1/auth/token" \
     -H "Content-Type: application/json" \
     -d '{
           "username": "admin", 
           "password": "mock_password_hash_replace_me"
         }'
# Expected Output: JSON containing "access_token". COPY THIS TOKEN.
```
**B. Fetch Data (Secured Read):** Use the copied token (`<YOUR_TOKEN>`) in the Authorization header.
```bash
# Example 1: Fetch FX Rate
curl -X GET "http://localhost:8000/api/v1/data/fx_rate?from_curr=USD&to_curr=EUR" \
     -H "Authorization: Bearer <YOUR_TOKEN>"

# Example 2: Fetch Metric
curl -X GET "http://localhost:8000/api/v1/data/metrics/housing_index" \
     -H "Authorization: Bearer <YOUR_TOKEN>"
```

### **STEP 5: Nginx Deployment Simulation (Phase 5)**
Once the API is confirmed to run on `localhost:8000`, Nginx is configured as a reverse proxy to expose it securely to the public internet.

**File to Create:** `nginx.conf` (Place this in a subdirectory, e.g., `./nginx/`)

```nginx
# Nginx Configuration Example (nginx.conf)
server {
    listen 80;
    server_name api.yourcompany.com; # Change to your actual domain

    location /api/v1/ {
        # Proxy to the running FastAPI service
        proxy_pass http://127.0.0.1:8000/api/v1/; 
        
        # Headers are critical for passing Auth and Client Info
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
    
    # Optional: Serve a simple HTML frontend or documentation landing page
    location / {
        root /var/www/html/mvp_frontend;
        index index.html;
    }
}
```

---
**Development Complete.** This comprehensive plan covers all specified requirements using the chosen stack.

What would you like to do next? (e.g., Run the initial setup, or Review the plan/code for any adjustments?)