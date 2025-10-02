from fastapi import FastAPI
from prometheus_client import Counter, Histogram, generate_latest, CONTENT_TYPE_LATEST
from fastapi.responses import PlainTextResponse
from .schemas import PredictRequest, PredictResponse
from .model import model
import time

app = FastAPI(title="ml-inference")
requests_total = Counter("inference_requests_total", "Total inference requests")
latency = Histogram("inference_latency_seconds", "Inference latency")

@app.get("/health/ready")
def readiness():
    return {"status": "ok"}

@app.get("/health/live")
def liveness():
    return {"status": "ok"}

@app.get("/metrics")
def metrics():
    return PlainTextResponse(generate_latest(), media_type=CONTENT_TYPE_LATEST)

@app.post("/predict", response_model=PredictResponse)
def predict(req: PredictRequest):
    requests_total.inc()
    start = time.time()
    species = model.predict(req.features)
    latency.observe(time.time() - start)
    return PredictResponse(species=species)