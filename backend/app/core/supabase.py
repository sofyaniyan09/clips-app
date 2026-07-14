from supabase import create_client, Client, ClientOptions
from .config import settings
import os

# Force load from OS environ to bypass any Pydantic .env caching issues, and strip whitespace!
service_key = os.environ.get("SUPABASE_SERVICE_KEY", settings.SUPABASE_SERVICE_KEY)
if service_key:
    service_key = service_key.strip()

# Initialize Supabase client
supabase: Client = create_client(
    settings.SUPABASE_URL, 
    settings.SUPABASE_KEY, 
    options=ClientOptions(postgrest_client_timeout=30.0, storage_client_timeout=30.0)
)
supabase_admin: Client = create_client(
    settings.SUPABASE_URL, 
    service_key, 
    options=ClientOptions(postgrest_client_timeout=30.0, storage_client_timeout=30.0)
)
