from typing import List, Optional

from datetime import datetime, timezone

from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session

from .. import models, schemas, auth
from ..database import get_db

router = APIRouter(prefix="/time-entries", tags=["time-entries"])


@router.post("/start", response_model=schemas.TimeEntryOut)
def start_tracking(
    payload: schemas.TimeEntryStart,
    db: Session = Depends(get_db),
    current_user: models.User = Depends(auth.get_current_user),
):
    existing = (
        db.query(models.TimeEntry)
        .filter(
            models.TimeEntry.user_id == current_user.id,
            models.TimeEntry.status == models.TimeEntryStatus.active,
        )
        .first()
    )
    if existing:
        raise HTTPException(status_code=400, detail="A tracking session is already active")

    entry = models.TimeEntry(
        user_id=current_user.id,
        project_id=payload.project_id,
        start_ip_address=payload.ip_address,
        status=models.TimeEntryStatus.active,
    )
    db.add(entry)
    db.commit()
    db.refresh(entry)
    return entry


@router.post("/{entry_id}/stop", response_model=schemas.TimeEntryOut)
def stop_tracking(
    entry_id: int,
    db: Session = Depends(get_db),
    current_user: models.User = Depends(auth.get_current_user),
):
    entry = (
        db.query(models.TimeEntry)
        .filter(models.TimeEntry.id == entry_id, models.TimeEntry.user_id == current_user.id)
        .first()
    )
    if not entry:
        raise HTTPException(status_code=404, detail="Time entry not found")
    if entry.status == models.TimeEntryStatus.stopped:
        return entry

    now = datetime.now(timezone.utc)
    entry.end_time = now
    entry.status = models.TimeEntryStatus.stopped
    start_time = entry.start_time
    if start_time.tzinfo is None:
        start_time = start_time.replace(tzinfo=timezone.utc)
    entry.duration_seconds = int((now - start_time).total_seconds())

    db.commit()
    db.refresh(entry)
    return entry


@router.get("/active", response_model=Optional[schemas.TimeEntryOut])
def get_active_entry(
    db: Session = Depends(get_db),
    current_user: models.User = Depends(auth.get_current_user),
):
    return (
        db.query(models.TimeEntry)
        .filter(
            models.TimeEntry.user_id == current_user.id,
            models.TimeEntry.status == models.TimeEntryStatus.active,
        )
        .first()
    )


@router.get("", response_model=List[schemas.TimeEntryOut])
def list_time_entries(
    user_id: Optional[int] = None,
    db: Session = Depends(get_db),
    current_user: models.User = Depends(auth.get_current_user),
):
    query = db.query(models.TimeEntry)
    if current_user.role == models.UserRole.admin:
        if user_id is not None:
            query = query.filter(models.TimeEntry.user_id == user_id)
    else:
        query = query.filter(models.TimeEntry.user_id == current_user.id)

    return query.order_by(models.TimeEntry.start_time.desc()).all()
