from contextlib import asynccontextmanager
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from dotenv import load_dotenv
import uvicorn

load_dotenv()

from routers import news, ai_summary


@asynccontextmanager
async def lifespan(app: FastAPI):
    yield


app = FastAPI(title="F1 News API", version="1.0.0", lifespan=lifespan)

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_methods=["GET", "POST"],
    allow_headers=["*"],
)

app.include_router(news.router, prefix="/api/v1")
app.include_router(ai_summary.router, prefix="/api/v1")


@app.get("/health")
async def health():
    return {"status": "ok"}


if __name__ == "__main__":
    uvicorn.run("main:app", host="0.0.0.0", port=8000, reload=True)
