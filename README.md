---
title: Clinical Oral RAG
emoji: 🧬
colorFrom: blue
colorTo: purple
sdk: streamlit
sdk_version: 1.32.0
app_file: app.py
pinned: false
---

# 🧬 The Clinical Oracle
### NIH Clinical Intelligence System — RAG Agent for Clinical Trial Protocols

> Ask complex clinical questions. Get answers grounded in NIH protocol documents — with sources, similarity scores, and LLM-as-Judge evaluation.

## 🎯 What it does

- ✅ Answers grounded exclusively in the retrieved context
- ✅ Source citations with similarity scores per chunk
- ✅ Real-time LLM-as-Judge quality evaluation
- ✅ Session archiving and full report download

## 🛠️ Tech Stack

| Component | Technology |
|---|---|
| LLM | Mistral AI (mistral-small-latest) |
| Embeddings | all-MiniLM-L6-v2 |
| Vector DB | ChromaDB |
| UI | Streamlit |

## 🔑 Requirements
- Python 3.11+
- Mistral API key 