FROM python:3.9-slim

WORKDIR /app

# Install dependencies
COPY app/backend/requirements-railway.txt .
RUN pip install --upgrade pip && pip install --no-cache-dir -r requirements-railway.txt

# Copy server + domain modules
COPY app/backend/14-APP-server.py .
COPY app/backend/domain/ domain/

# Copy AI patterns and evaluation scripts
COPY ai/patterns/ ai/patterns/
COPY ai/ragas/ ai/ragas/

# Environment variables (overridden at runtime via .env or docker-compose)
ENV PORT=9999

EXPOSE 9999

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
  CMD python3 -c "import urllib.request; urllib.request.urlopen('http://localhost:9999/api/health', timeout=5)" || exit 1

CMD ["python3", "14-APP-server.py"]
