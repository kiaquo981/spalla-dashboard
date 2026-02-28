FROM python:3.9-slim

WORKDIR /app

# Copy server
COPY 14-APP-server.py .

# Environment variables (will be overridden at runtime)
ENV PORT=9999
ENV ZOOM_ACCOUNT_ID=${ZOOM_ACCOUNT_ID}
ENV ZOOM_CLIENT_ID=${ZOOM_CLIENT_ID}
ENV ZOOM_CLIENT_SECRET=${ZOOM_CLIENT_SECRET}
ENV SUPABASE_ANON_KEY=${SUPABASE_ANON_KEY}
ENV SUPABASE_SERVICE_KEY=${SUPABASE_SERVICE_KEY}
ENV EVOLUTION_API_KEY=${EVOLUTION_API_KEY}

EXPOSE 9999

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
  CMD python3 -c "import urllib.request; urllib.request.urlopen('http://localhost:9999/api/health', timeout=5)" || exit 1

CMD ["python3", "14-APP-server.py"]
