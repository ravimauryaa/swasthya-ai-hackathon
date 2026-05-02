# 🏥 SwasthyaAI: Intelligent Medical Triage System

**SwasthyaAI** is an AI-powered diagnostic and triage solution that provides users with real-time medical advice and severity assessments based on their symptoms. Its goal is to bridge the gap between emergency cases (RED) and general symptoms (GREEN).

---

## 🚀 Key Features

- **Smart Triage Engine**: Uses Gemini 2.5 Flash to classify symptoms into RED, YELLOW, and GREEN categories.
- **Agentic RAG Architecture**: Fetches verified medical guidelines using Pinecone Vector Database and `all-mpnet-base-v2` embeddings.
- **Multilingual Support**: Supports Hindi/Hinglish responses so common users can easily understand the advice.
- **Voice Input**: Users can speak their symptoms using the `speech_to_text` integration.
- **High-Speed Local Hosting**: Server is hosted on a local network (Mac M1) to minimize latency.

---

## 🏗️ System Architecture

```
User Input (Text/Voice)
        ↓
  Flutter App (Dio)
        ↓
  FastAPI Backend
    ├── Agent 1: Pinecone Vector Search (all-mpnet-base-v2)
    └── Agent 2: Gemini 2.5 Flash Reasoning
        ↓
  JSON Response { severity, action }
        ↓
  Visual Alert (🔴 RED / 🟡 YELLOW / 🟢 GREEN)
```

---

## 🛠️ Tech Stack

| Layer | Technology |
| :--- | :--- |
| **Mobile Frontend** | Flutter (Dart) — `dio`, `provider`, `speech_to_text`, `google_fonts` |
| **API Backend** | FastAPI (Python) |
| **AI Models** | Google Gemini 2.5 Flash, `sentence-transformers/all-mpnet-base-v2` |
| **Vector DB** | Pinecone (`swasthya-db` index) |
| **DevOps** | Uvicorn on `0.0.0.0:8000`, Git/GitHub |

---

## 💻 Installation & Setup

### Backend

1. Create a `.env` file:
   ```env
   GEMINI_API_KEY=YOUR_GEMINI_KEY
   PINECONE_API_KEY=YOUR_PINECONE_KEY
   ```

2. Install dependencies:
   ```bash
   cd swasthya_ai_backend
   pip install -r requirements.txt
   ```

3. Start the server:
   ```bash
   python main.py
   # Server runs at http://0.0.0.0:8000
   ```

### Flutter App

1. Install dependencies:
   ```bash
   cd swasthya_ai_app
   flutter pub get
   ```

2. Set your local server IP in `lib/services/api_service.dart`.

3. Run the app:
   ```bash
   flutter run
   ```

---

## 📡 API Reference

### `POST /api/triage`

**Request:**
```json
{
  "text": "chest pain and shortness of breath",
  "language": "Hindi"
}
```

**Response:**
```json
{
  "status": "success",
  "ai_response": {
    "severity": "RED",
    "action": "Go to the nearest hospital immediately."
  }
}
```

**Severity Levels:**
| Level | Meaning |
| :--- | :--- |
| 🔴 RED | Emergency — immediate medical attention needed |
| 🟡 YELLOW | Moderate — consult a doctor soon |
| 🟢 GREEN | Mild — home care / OPD visit |

---

## 📁 Project Structure

```
swasthya_ai/
├── swasthya_ai_backend/
│   ├── main.py          # FastAPI app with triage endpoint
│   ├── seed_data.py     # Pinecone data seeding script
│   ├── requirements.txt
│   └── .env
└── swasthya_ai_app/
    └── lib/
        ├── main.dart
        ├── features/    # home_screen, result_screen, main_layout
        ├── models/      # triage_model.dart
        └── services/    # api_service.dart
```
