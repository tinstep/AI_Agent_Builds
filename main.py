# main.py - FastAPI Web API Gateway

from pydantic import BaseModel
from fastapi import FastAPI, Depends, HTTPException, status, Body
from fastapi.security import OAuth2PasswordBearer
from datetime import datetime
from typing import List, Dict, Any
import uvicorn

# --- Imports from our local modules ---
from data_access import fetch_latest_rates, fetch_latest_metric, get_db_connection
from auth_service import get_current_user_context, login_user, check_usage_limit

# --- Pydantic Model for Login Request ---
class LoginRequest(BaseModel):
    username: str
    password: str

# --- Initialization ---
app = FastAPI(
    title="Economic Data API",
    description="MVP API Gateway for consuming standardized economic data, secured by JWT.",
    version="0.1.0"
)

# OAuth2 Scheme definition (used for security header validation)
oauth2_scheme = OAuth2PasswordBearer(tokenUrl="api/v1/auth/token")

# --- Dependency Functions (The Core Security/Rate Limiting Hook) ---

def get_current_user(token: str = Depends(oauth2_scheme)):
    """
    Dependency function that validates the JWT token and returns the user context.
    This acts as the middleware.
    """
    user_context = get_current_user_context(token)
    if not user_context:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Invalid or expired authentication token.",
            headers={"WWW-Authenticate": "Bearer"},
        )
    
    # Usage Check Integration (Phase 2 Dependency)
    # NOTE: This uses the in-memory counter. In production, this must hit a persistent DB/Cache.
    if not check_usage_limit(user_context['user_id'], user_context['plan_type']):
        raise HTTPException(
            status_code=status.HTTP_429_TOO_MANY_REQUESTS,
            detail=f"Usage limit exceeded for plan '{user_context['plan_type']}'. Quota reset daily."
        )
        
    return user_context

# --- API Endpoints ---

@app.post("/api/v1/auth/token")
async def login_for_access_token(login: LoginRequest):
    """
    Phase 2: Login endpoint. Generates a JWT token upon successful credential verification.
    Client should use this endpoint first to get a token, then pass it in the Authorization header for all other calls.
    """
    # This simulates the secure login flow using the services written in auth_service.py
    token = login_user(login.username, login.password)
    if not token:
        raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail="Could not validate credentials.")
    
    return {"access_token": token, "token_type": "bearer"}

@app.get("/api/v1/data/fx_rate")
async def get_fx_rate(
    from_curr: str, 
    to_curr: str, 
    # Dependency injection handles security and rate limiting automatically
    user_context: Dict[str, Any] = Depends(get_current_user)
):
    """
    Phase 4: Retrieves the latest FX rate for the given pair, secured by Auth.
    """
    # --- Rate Limiting Logic Placeholder ---
    # Actual usage increment would happen here, using user_context['user_id']
    # For MVP, we just proceed.
    
    # Data Retrieval (Phase 1 Dependency)
    rate_data = fetch_latest_rates(from_curr, to_curr)
    
    if not rate_data:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail=f"No rate found for {from_curr}/{to_curr} in the historical data.")
    
    return {
        "status": "success",
        "data": {
            "from": from_curr,
            "to": to_curr,
            "rate": rate_data['rate'],
            "timestamp": rate_data['timestamp'],
            "retrieved_by_user_plan": user_context['plan_type']
        }
    }

@app.get("/api/v1/data/metrics/{metric_name}")
async def get_metric_data(
    metric_name: str,
    user_context: Dict[str, Any] = Depends(get_current_user)
):
    """
    Phase 4: Retrieves the latest general economic metric, secured by Auth.
    """
    # --- Rate Limiting Placeholder ---
    
    # Data Retrieval (Phase 1 Dependency)
    metric_data = fetch_latest_metric(metric_name)
    
    if not metric_data:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail=f"Metric '{metric_name}' not found in data.")
    
    return {
        "status": "success",
        "data": {
            "metric_name": metric_name,
            "value": metric_data['value'],
            "timestamp": metric_data['timestamp'],
            "source": metric_data['source'],
            "retrieved_by_user_plan": user_context['plan_type']
        }
    }


# --- Development Helper ---
def start_server():
    """
    Starts the FastAPI server. This should ideally be run by a process manager 
    like Gunicorn, but we use uvicorn for the local MVP test.
    """
    print("\n===========================================================================")
    print("🚀 API Gateway Running! Access documentation at: http://127.0.0.1:8000/docs")
    print("===========================================================================")
    # Runs the server, requiring the user to run this script
    uvicorn.run("main:app", host="127.0.0.1", port=8000, reload=True)


if __name__ == "__main__":
    # This block allows running the API directly from the command line
    start_server()
