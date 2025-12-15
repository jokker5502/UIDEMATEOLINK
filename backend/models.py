from typing import Optional
import uuid
from datetime import datetime, date, time
from enum import Enum
from sqlmodel import SQLModel, Field


class TripType(str, Enum):
    ENTRY = "ENTRY"
    EXIT = "EXIT"


class Bus(SQLModel, table=True):
    __tablename__ = "buses"
    id: Optional[int] = Field(default=None, primary_key=True)
    bus_number: str
    is_active: bool = True


class Route(SQLModel, table=True):
    __tablename__ = "routes"
    id: Optional[int] = Field(default=None, primary_key=True)
    code: str
    name: str
    is_active: bool = True


class QRSlot(SQLModel, table=True):
    __tablename__ = "qr_slots"
    id: Optional[int] = Field(default=None, primary_key=True)

    bus_id: int = Field(foreign_key="buses.id")
    route_id: int = Field(foreign_key="routes.id")

    trip_type: TripType
    scheduled_time: time

    token: str = Field(index=True, unique=True)
    is_active: bool = True


class ScanEvent(SQLModel, table=True):
    __tablename__ = "scan_events"

    id: Optional[int] = Field(default=None, primary_key=True)

    qr_slot_id: int = Field(foreign_key="qr_slots.id")

    client_event_id: uuid.UUID = Field(
        default_factory=uuid.uuid4,
        nullable=False,
        index=True
    )

class ScanCounter(SQLModel, table=True):
    __tablename__ = "scan_counters"
    id: Optional[int] = Field(default=None, primary_key=True)

    qr_slot_id: int = Field(foreign_key="qr_slots.id")
    day: date
    count: int = 0


scanned_at: datetime = Field(default_factory=datetime.utcnow)
