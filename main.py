import datetime
import os
import bcrypt
from typing import List, Optional
from fastapi import FastAPI, Depends, HTTPException, status
from fastapi.security import OAuth2PasswordBearer, OAuth2PasswordRequestForm
from fastapi.middleware.cors import CORSMiddleware  # Добавили CORS
from sqlalchemy import create_engine, Column, Integer, String, desc
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy.orm import sessionmaker, Session
from jose import JWTError, jwt
from pydantic import BaseModel

SQLALCHEMY_DATABASE_URL = os.getenv(
    "DATABASE_URL",
    "postgresql://game_user:mysecretpassword@localhost:5433/game_db"
)

SECRET_KEY = os.getenv("SECRET_KEY", "fallback_local_secret_key_for_testing_123")
ALGORITHM = "HS256"
ACCESS_TOKEN_EXPIRE_MINUTES = 60 * 24

engine = create_engine(SQLALCHEMY_DATABASE_URL)
SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)
Base = declarative_base()


class UserDB(Base):
    __tablename__ = "players"
    id = Column(Integer, primary_key=True, index=True)
    username = Column(String, unique=True, index=True, nullable=False)
    hashed_password = Column(String, nullable=False)
    score = Column(Integer, default=0)
    
    gold = Column(Integer, default=100)
    floor_1 = Column(Integer, nullable=True, default=None)
    floor_2 = Column(Integer, nullable=True, default=None)
    floor_3 = Column(Integer, nullable=True, default=None)


Base.metadata.create_all(bind=engine)


class UserCreate(BaseModel):
    username: str
    password: str


class UserOut(BaseModel):
    username: str
    score: int
    gold: int
    floor_1: Optional[int]
    floor_2: Optional[int]
    floor_3: Optional[int]
    
    class Config:
        from_attributes = True


class Token(BaseModel):
    access_token: str
    token_type: str


class ScoreSubmit(BaseModel):
    score: int


class TowerSave(BaseModel):
    gold: int
    floor_1: Optional[int]
    floor_2: Optional[int]
    floor_3: Optional[int]


def hash_password(password: str) -> str:
    salt = bcrypt.gensalt()
    hashed = bcrypt.hashpw(password.encode('utf-8'), salt)
    return hashed.decode('utf-8')


def verify_password(plain_password: str, hashed_password: str) -> bool:
    return bcrypt.checkpw(plain_password.encode('utf-8'), hashed_password.encode('utf-8'))


def create_access_token(data: dict):
    to_encode = data.copy()
    expire = datetime.datetime.utcnow() + datetime.timedelta(minutes=ACCESS_TOKEN_EXPIRE_MINUTES)
    to_encode.update({"exp": expire})
    return jwt.encode(to_encode, SECRET_KEY, algorithm=ALGORITHM)


def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()


oauth2_scheme = OAuth2PasswordBearer(tokenUrl="login")


async def get_current_user(token: str = Depends(oauth2_scheme), db: Session = Depends(get_db)):
    credentials_exception = HTTPException(
        status_code=status.HTTP_401_UNAUTHORIZED,
        detail="Could not validate credentials",
        headers={"WWW-Authenticate": "Bearer"},
    )
    try:
        payload = jwt.decode(token, SECRET_KEY, algorithms=[ALGORITHM])
        username: str = payload.get("sub")
        if username is None:
            raise credentials_exception
    except JWTError:
        raise credentials_exception
    
    user = db.query(UserDB).filter(UserDB.username == username).first()
    if user is None:
        raise credentials_exception
    return user


app = FastAPI(title="Godot Game Server")

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)


@app.post("/register", response_model=UserOut)
def register(user_data: UserCreate, db: Session = Depends(get_db)):
    db_user = db.query(UserDB).filter(UserDB.username == user_data.username).first()
    if db_user:
        raise HTTPException(status_code=400, detail="Username already registered")
    
    new_user = UserDB(
        username=user_data.username,
        hashed_password=hash_password(user_data.password),
    )
    db.add(new_user)
    db.commit()
    db.refresh(new_user)
    return new_user


@app.post("/login", response_model=Token)
def login(form_data: OAuth2PasswordRequestForm = Depends(), db: Session = Depends(get_db)):
    user = db.query(UserDB).filter(UserDB.username == form_data.username).first()
    
    if not user or not verify_password(form_data.password, user.hashed_password):
        raise HTTPException(status_code=400, detail="Incorrect username or password")
    
    access_token = create_access_token(data={"sub": user.username})
    return {"access_token": access_token, "token_type": "bearer"}


@app.post("/submit_score")
def submit_score(data: ScoreSubmit, current_user: UserDB = Depends(get_current_user), db: Session = Depends(get_db)):
    is_new_record = False
    if data.score > current_user.score:
        current_user.score = data.score
        db.commit()
        is_new_record = True
    
    return {
        "status": "ok",
        "new_record": is_new_record,
        "current_score": current_user.score
    }


@app.post("/save_progress", response_model=UserOut)
def save_progress(data: TowerSave, current_user: UserDB = Depends(get_current_user), db: Session = Depends(get_db)):
    current_user.gold = data.gold
    current_user.floor_1 = data.floor_1
    current_user.floor_2 = data.floor_2
    current_user.floor_3 = data.floor_3
    
    db.commit()
    db.refresh(current_user)
    return current_user


@app.get("/leaderboard", response_model=List[UserOut])
def get_leaderboard(db: Session = Depends(get_db)):
    users = db.query(UserDB).order_by(desc(UserDB.score)).limit(10).all()
    return users


@app.get("/me", response_model=UserOut)
def get_me(current_user: UserDB = Depends(get_current_user)):
    return current_user


if __name__ == "__main__":
    import uvicorn

    port = int(os.getenv("PORT", 8000))
    uvicorn.run(app, host="0.0.0.0", port=port)
