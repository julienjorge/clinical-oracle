FROM python:3.11-slim

# Utilisateur non root, attendu par Hugging Face Spaces
RUN useradd -m -u 1000 user
USER user
ENV PATH="/home/user/.local/bin:$PATH"

WORKDIR /app

# Dépendances Python (installées avant le code pour profiter du cache Docker)
COPY --chown=user requirements.txt requirements.txt
RUN pip install --no-cache-dir --upgrade -r requirements.txt

# Code, textes extraits et PDF ; chroma_db est reconstruit au démarrage par app.py
COPY --chown=user . /app

# Modèle d'embedding téléchargé dans le conteneur (dossier accessible en écriture)
ENV HF_HOME=/home/user/.cache/huggingface

EXPOSE 7860
CMD ["streamlit", "run", "app.py", "--server.port=7860", "--server.address=0.0.0.0", "--server.headless=true"]
