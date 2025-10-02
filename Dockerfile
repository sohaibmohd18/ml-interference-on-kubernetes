# Build stage - use non-root user
FROM python:3.11-slim AS builder

# Create non-root user for build stage
RUN adduser --disabled-password --gecos "" --uid 1000 builduser

# Install security updates
RUN apt-get update && \
    apt-get upgrade -y && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /app
COPY app/requirements.txt .

# Create wheels directory and change ownership
RUN mkdir -p /wheels && \
    chown -R builduser:builduser /app /wheels
USER builduser

# Build wheels with hash checking
RUN pip wheel --no-cache-dir --no-deps -r requirements.txt -w /wheels

# Run stage (non-root)
FROM python:3.11-slim

ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    PIP_NO_CACHE_DIR=1 \
    PIP_DISABLE_PIP_VERSION_CHECK=1

# Install security updates
RUN apt-get update && \
    apt-get upgrade -y && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Create non-root user with specific UID
RUN adduser --disabled-password --gecos "" --uid 1001 appuser

WORKDIR /app

# Copy wheels and install with verification
COPY --from=builder --chown=appuser:appuser /wheels /wheels
COPY --chown=appuser:appuser app/requirements.txt .

# Install packages with hash verification (recommend adding --require-hashes to requirements.txt)
RUN pip install --no-cache-dir --no-index --find-links=/wheels -r requirements.txt && \
    rm -rf /wheels

COPY --chown=appuser:appuser app /app/app

USER appuser
EXPOSE 8080

# Use exec form for better signal handling
CMD ["uvicorn", "app.src.main:app", "--host", "0.0.0.0", "--port", "8080"]