---
title: The Clinical Oracle
emoji: 🧬
colorFrom: blue
colorTo: purple
sdk: docker
app_port: 7860
pinned: false
---

# 🧬 The Clinical Oracle
### Assistant RAG pour les protocoles d'essais cliniques du NIH

> Posez une question clinique, obtenez une réponse fondée sur les protocoles, avec ses sources, les scores de similarité et une évaluation automatique de la qualité.

## Le projet

Les protocoles d'essais cliniques publiés par le NIH sont des PDF longs et denses. Trouver une information précise demande de les lire en entier.

Nous avons construit un système RAG (Retrieval-Augmented Generation) : pour chaque question, le système cherche les passages pertinents dans les protocoles, puis demande à un modèle de langage de répondre uniquement à partir de ces passages, en citant ses sources. Il fournit :

- ✅ des réponses fondées exclusivement sur les passages retrouvés ;
- ✅ les sources citées, avec un score de similarité par passage ;
- ✅ une évaluation automatique de chaque réponse (LLM-as-Judge) ;
- ✅ l'archivage des sessions et le téléchargement d'un rapport.

Le projet comprend un notebook, qui construit la base et évalue le système, et une application web Streamlit déployée sur Hugging Face.

## Les données

- **20 protocoles d'essais cliniques du NIH** au format PDF, publics, dans le dossier docs. Les sujets sont variés : cancer de l'ovaire, tendinopathie de l'épaule, greffe de cellules souches, etc.
- **19 documents exploitables sur 20** : un PDF est un document scanné sans texte.

## Comment ça marche

1. **Extraction** : chaque PDF est converti en texte avec Unstructured, en conservant le type de chaque élément (titre, paragraphe, liste) et son numéro de page.
2. **Découpage** : les textes sont coupés en morceaux (chunks) de 1 000 caractères avec un recouvrement de 200, soit 847 chunks.
3. **Embeddings** : chaque chunk est transformé en vecteur de 384 nombres qui représente son sens, avec le modèle all-MiniLM-L6-v2, exécuté en local.
4. **Base vectorielle** : les vecteurs sont stockés sur disque dans ChromaDB.
5. **Agent RAG** : la question est reformulée par le modèle de langage, les 8 passages les plus proches sont retrouvés, puis Mistral rédige la réponse à partir de ces seuls passages, en citant le fichier source.
6. **Évaluation** : un second appel au modèle note chaque réponse de 0 à 10 sur quatre critères (fidélité au contexte, pertinence, complétude, citation des sources).

Trois choix importants :

- **Séparer extraction et indexation.** Les textes extraits sont enregistrés sur disque : on peut réindexer avec d'autres paramètres sans relire les PDF.
- **Température à 0 et consigne stricte d'ancrage.** Le modèle répond uniquement à partir des passages fournis et signale ce qu'il ne trouve pas.
- **Base reconstruite au démarrage de l'application.** La base vectorielle n'est pas versionnée : l'application la régénère depuis les textes extraits si elle est absente.

## Les résultats

Évaluation LLM-as-Judge sur cinq questions :

| Critère | Score |
|---|---|
| Fidélité au contexte | 8,8 / 10 |
| Pertinence | 9,2 / 10 |
| Complétude | 8,2 / 10 |
| Citation des sources | 10 / 10 |
| **Global** | **9,1 / 10** |

La similarité moyenne entre la question et les passages retrouvés se situe entre 53 et 62 %.

## Exécuter le projet

Arborescence :

- Clinical_Oracle_FINAL.ipynb : construction de la base et évaluation
- app.py : application Streamlit
- Dockerfile, .dockerignore, requirements.txt : déploiement
- .env.example : variables d'environnement attendues
- docs/ : les 20 PDF d'origine
- docs_txt/, chroma_db/, evaluation_report.json : produits par le notebook

Prérequis : Python 3.11 ou plus, une clé API Mistral (console.mistral.ai), les librairies de requirements.txt.

Configuration : copier .env.example en .env et y renseigner MISTRAL_API_KEY.

Lancement :

- le notebook s'exécute de bout en bout depuis la racine du projet ;
- l'application se lance avec `streamlit run app.py` ; si chroma_db est absent, elle le reconstruit depuis docs_txt (2 à 3 minutes) ;
- en ligne : https://julienvmj-clinical-oracle-3125204.hf.space

## Limites et suites possibles

- **Le juge est le même modèle que le générateur** et l'évaluation repose sur cinq questions : un jeu plus large, avec des réponses de référence, donnerait une mesure plus stable.
- **Le modèle d'embedding est généraliste** ; un modèle entraîné sur des textes médicaux améliorerait la recherche.
- **Le PDF scanné et les tableaux ne sont pas exploités** ; un mode d'extraction avec reconnaissance de caractères les récupérerait.
