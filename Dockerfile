# Build stage
FROM python:3.11-slim AS builder
WORKDIR /app
COPY app/requirements.txt .
RUN pip wheel --no-cache-dir --no-deps -r requirements.txt -w /wheels

# Run stage (non-root)
FROM python:3.11-slim
ENV PYTHONDONTWRITEBYTECODE=1 PYTHONUNBUFFERED=1
RUN adduser --disabled-password --gecos "" appuser
WORKDIR /app
COPY --from=builder /wheels /wheels
COPY app/requirements.txt .
RUN pip install --no-cache-dir --no-index --find-links=/wheels -r requirements.txt
COPY app /app/app
USER appuser
EXPOSE 8080
CMD ["uvicorn", "app.src.main:app", "--host", "0.0.0.0", "--port", "8080"]