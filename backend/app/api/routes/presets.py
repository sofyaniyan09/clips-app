from fastapi import APIRouter, Depends, HTTPException, status
from typing import List
from app.models.schemas import PresetCreate, PresetResponse, PresetUpdate
from app.core.security import get_current_user
from app.core.supabase import supabase_admin
import uuid

router = APIRouter()

@router.get("/", response_model=List[PresetResponse])
def get_presets(user = Depends(get_current_user)):
    user_id = user.id if hasattr(user, 'id') else user.get('id')
    response = supabase_admin.table('presets').select("*").eq('user_id', user_id).execute()
    return response.data

@router.post("/", response_model=PresetResponse, status_code=status.HTTP_201_CREATED)
def create_preset(preset: PresetCreate, user = Depends(get_current_user)):
    """Create a new preset."""
    data = preset.model_dump()
    user_id = user.id if hasattr(user, 'id') else user.get('id')
    data["user_id"] = user_id
    
    response = supabase_admin.table('presets').insert(data).execute()
    if not response.data:
        raise HTTPException(status_code=400, detail="Failed to create preset")
    return response.data[0]

@router.put("/{preset_id}", response_model=PresetResponse)
def update_preset(preset_id: str, preset: PresetUpdate, user = Depends(get_current_user)):
    """Update an existing preset."""
    user_id = user.id if hasattr(user, 'id') else user.get('id')
    existing = supabase_admin.table('presets').select("*").eq('id', preset_id).eq('user_id', user_id).execute()
    if not existing.data:
        raise HTTPException(status_code=404, detail="Preset not found or not authorized")
        
    update_data = preset.model_dump(exclude_unset=True)
    if not update_data:
        return existing.data[0]
        
    response = supabase_admin.table('presets').update(update_data).eq('id', preset_id).execute()
    return response.data[0]

@router.delete("/{preset_id}", status_code=status.HTTP_204_NO_CONTENT)
def delete_preset(preset_id: str, user = Depends(get_current_user)):
    """Delete a preset."""
    user_id = user.id if hasattr(user, 'id') else user.get('id')
    existing = supabase_admin.table('presets').select("*").eq('id', preset_id).eq('user_id', user_id).execute()
    if not existing.data:
        raise HTTPException(status_code=404, detail="Preset not found or not authorized")
        
    supabase_admin.table('presets').delete().eq('id', preset_id).execute()
    return None
