# 🏥 SwasthyaAI: Intelligent Medical Triage System

**SwasthyaAI** ek AI-powered diagnostic and triage solution hai jo users ko unke symptoms ke basis par real-time medical advice aur severity assessments provide karta hai. Iska goal emergency cases (RED) aur general symptoms (GREEN) ke beech ka gap kam karna hai.

---

## 🚀 Key Features

- **Smart Triage Engine**: Gemini 2.5 Flash ka use karke symptoms ko RED, YELLOW, aur GREEN categories mein classify karta hai.
- **Agentic RAG Architecture**: Pinecone Vector Database aur `all-mpnet-base-v2` embeddings ka use karke verified medical guidelines fetch karta hai.
- **Multilingual Support**: Hinglish/Hindi support taaki common users ko samajhne mein aasani ho.
- **Voice Input**: `speech_to_text` se symptoms bolkar bhi enter kar sakte hain.
- **High-Speed Local Hosting**: Latency kam karne ke liye server Mac M1 par local network par host kiya gaya hai.

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

1. `.env` file banayein:
   ```env
   GEMINI_API_KEY=YOUR_GEMINI_KEY
   PINECONE_API_KEY=YOUR_PINECONE_KEY
   ```

2. Dependencies install karein:
   ```bash
   cd swasthya_ai_backend
   pip install -r requirements.txt
   ```

3. Server start karein:
   ```bash
   python main.py
   # Server runs at http://0.0.0.0:8000
   ```

### Flutter App

1. Dependencies install karein:
   ```bash
   cd swasthya_ai_app
   flutter pub get
   ```

2. `lib/services/api_service.dart` mein apna local server IP set karein.

3. App run karein:
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
    "action": "तुरंत नजदीकी अस्पताल जाएं।"
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
