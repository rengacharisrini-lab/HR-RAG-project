# HR Support Chatbot (RAG, Streamlit UI) — container image for Cloud Run (or any Docker host)
FROM python:3.11-slim

WORKDIR /app

# Install dependencies first for better layer caching
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy application code, the prebuilt FAISS index, and source PDFs.
# .env is intentionally excluded via .dockerignore — never bake secrets into the image.
COPY . .

# Which Streamlit entry point to run: "app.py" (no memory) or "app_with_memory.py" (context-aware,
# recommended). Override at build time with --build-arg STREAMLIT_APP=app.py if you want the
# no-memory version instead.
ARG STREAMLIT_APP=app_with_memory.py
ENV STREAMLIT_APP=${STREAMLIT_APP}

# Cloud Run injects PORT at runtime; default to 8080 for local `docker run`.
ENV PORT=8080
EXPOSE 8080

# Headless + CORS/XSRF disabled: required for Streamlit to run correctly behind Cloud Run's proxy.
CMD ["sh", "-c", "streamlit run ${STREAMLIT_APP} --server.port=${PORT} --server.address=0.0.0.0 --server.headless=true --server.enableCORS=false --server.enableXsrfProtection=false"]
