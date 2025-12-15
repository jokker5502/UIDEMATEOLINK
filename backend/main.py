from datetime import date
from fastapi import FastAPI, Depends, HTTPException
from sqlmodel import Session, select
import uuid

from db import get_session
from models import QRSlot, ScanEvent, ScanCounter

app = FastAPI(title="QR Bus Counter MVP")


@app.get("/s/{token}")
def scan_qr(token: str, session: Session = Depends(get_session)):
    # 1. Buscar QR
    qr_slot = session.exec(
        select(QRSlot).where(QRSlot.token == token, QRSlot.is_active == True)
    ).first()

    if not qr_slot:
        raise HTTPException(status_code=404, detail="QR no válido")

    # 2. Registrar evento
    scan = ScanEvent(
    qr_slot_id=qr_slot.id,
    client_event_id=uuid.uuid4()
    )

    session.add(scan)

    # 3. Incrementar contador diario
    today = date.today()
    counter = session.exec(
        select(ScanCounter)
        .where(
            ScanCounter.qr_slot_id == qr_slot.id,
            ScanCounter.day == today
        )
    ).first()

    if counter:
        counter.count += 1
    else:
        counter = ScanCounter(
            qr_slot_id=qr_slot.id,
            day=today,
            count=1
        )
        session.add(counter)

    session.commit()

    return {
        "message": "Registro exitoso",
        "total": counter.count
    }
