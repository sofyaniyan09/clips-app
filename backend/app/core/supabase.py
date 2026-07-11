from supabase import create_client, Client, ClientOptions
from .config import settings

options = ClientOptions(postgrest_client_timeout=30.0, storage_client_timeout=30.0)

# Initialize Supabase client
supabase: Client = create_client(settings.SUPABASE_URL, settings.SUPABASE_KEY, options=options)
supabase_admin: Client = create_client(settings.SUPABASE_URL, settings.SUPABASE_SERVICE_KEY, options=options)
