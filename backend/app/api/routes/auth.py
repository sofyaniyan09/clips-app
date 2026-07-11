from fastapi import APIRouter, HTTPException
from pydantic import BaseModel
from app.core.supabase import supabase

router = APIRouter()

class LoginRequest(BaseModel):
    email: str
    password: str

@router.post("/login")
def login(credentials: LoginRequest):
    """
    Login endpoint for testing purposes.
    Takes email and password, authenticates with Supabase, and returns the JWT token.
    You can copy the 'access_token' from the response and paste it into the Swagger 'Authorize' button.
    """
    try:
        response = supabase.auth.sign_in_with_password({
            "email": credentials.email,
            "password": credentials.password
        })
        return {
            "access_token": response.session.access_token,
            "token_type": "bearer",
            "user": response.user
        }
    except Exception as e:
        raise HTTPException(status_code=400, detail=f"Login failed: {str(e)}")
