from sqlmodel import create_engine, Session

DATABASE_URL = "postgresql://uide:Contra.123.contra@localhost:5432/uide_link"

engine = create_engine(
    DATABASE_URL,
    echo=False
)

def get_session():
    with Session(engine) as session:
        yield session
