# 🏥 SwasthyaAI: Intelligent Medical Triage System

**SwasthyaAI** is an AI-powered diagnostic and triage solution that provides users with real-time medical advice and severity assessments based on their symptoms. It bridges the gap between emergency cases (RED) and general symptoms (GREEN), with ABHA integration, voice input, local medical history, and an AI medical scribe.

---

## 🚀 Key Features

- **Smart Triage Engine**: Uses Gemini 2.5 Flash to classify symptoms into RED, YELLOW, and GREEN categories.
- **Agentic RAG Architecture**: Fetches verified medical guidelines using Pinecone Vector Database and `all-mpnet-base-v2` embeddings.
- **ABHA Integration**: Fetches patient profile (chronic conditions, allergies, blood group) via ABHA ID to personalize triage advice.
- **AI Medical Scribe**: Converts raw patient transcripts into structured HPI (History of Present Illness) reports for doctors.
- **Local Medical Ledger**: Automatically saves every triage result to the device using `SharedPreferences`.
- **Emergency Actions**: One-tap buttons to find nearest hospital (Google Maps), call ambulance (108), and alert family via SMS.
- **Doctor Handover Summary**: Displays patient profile + triage result in a ready-to-read card for doctors.
- **Voice Input**: Users can speak symptoms using `speech_to_text` with Hindi and English support.
- **Text-to-Speech**: AI advice is read aloud using `flutter_tts`.
- **Multilingual Support**: Full Hindi and English support across the app and backend.
- **High-Speed Local Hosting**: Server hosted on local network (Mac M1) to minimize latency.

---

## 🏗️ System Architecture

```
User Input (Text / Voice)
        ↓
  Flutter App (Dio)
        ↓
  FastAPI Backend
    ├── Agent 1: Pinecone Vector Search (all-mpnet-base-v2)  ← RAG
    ├── Agent 2: Gemini 2.5 Flash Reasoning                  ← AI Triage
    ├── ABHA Mock DB                                          ← Patient History
    └── AI Scribe Engine                                      ← Doctor Report
        ↓
  JSON Response { severity, action }
        ↓
  Flutter UI
    ├── 🔴 RED  → Emergency Actions (Maps, 108, SMS)
    ├── 🟡 YELLOW → Doctor Handover Summary
    └── 🟢 GREEN → Home Care Advice
```

---

## 🛠️ Tech Stack

| Layer | Technology |
| :--- | :--- |
| **Mobile Frontend** | Flutter (Dart) — `dio`, `provider`, `speech_to_text`, `flutter_tts`, `google_fonts`, `avatar_glow`, `animate_do`, `shared_preferences`, `url_launcher` |
| **API Backend** | FastAPI (Python) |
| **AI Models** | Google Gemini 2.5 Flash, `sentence-transformers/all-mpnet-base-v2` |
| **Vector DB** | Pinecone (`swasthya-db` index) |
| **DevOps** | Uvicorn on `0.0.0.0:8000`, Git/GitHub |

---

## 📱 App Screens

| Screen | Description |
| :--- | :--- |
| **Triage (Home)** | Voice/text symptom input, language toggle (Hindi/English), analyze button |
| **Result** | Severity alert, AI advice, TTS playback, emergency actions, doctor handover card |
| **History** | Local medical ledger — all past triage results saved on device |
| **ABHA** | Scan/enter ABHA ID to fetch and link patient profile |
| **Consult** | AI Medical Scribe — converts consultation transcript to structured HPI report |
| **Profile** | Displays linked ABHA patient profile details |

---

## 💻 Installation & Setup

### Prerequisites

- Python 3.9+
- Flutter 3.x (Dart SDK ^3.11.5)
- Pinecone account with a `swasthya-db` index (dimension: 768)
- Google Gemini API key

### Backend

1. Create a `.env` file in `swasthya_ai_backend/`:
   ```env
   GEMINI_API_KEY=YOUR_GEMINI_KEY
   PINECONE_API_KEY=YOUR_PINECONE_KEY
   ```

2. Install dependencies:
   ```bash
   cd swasthya_ai_backend
   pip install -r requirements.txt
   ```

3. Seed the Pinecone vector database (run once):
   ```bash
   python seed_data.py
   ```

4. Start the server:
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

2. Set your local server IP in `lib/services/api_service.dart`:
   ```dart
   final String _apiUrl = "http://<YOUR_LOCAL_IP>:8000";
   ```

3. Run the app:
   ```bash
   flutter run
   ```

---

## 📡 API Reference

### `POST /api/triage`
Analyzes symptoms and returns severity + advice.

**Request:**
```json
{
  "text": "chest pain and shortness of breath",
  "language": "Hindi",
  "patient_history": {
    "name": "Ramesh Kumar",
    "age": 55,
    "chronic_conditions": ["Diabetes Type 2"],
    "allergies": ["Penicillin"]
  }
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

---

### `GET /api/v1/abha/patient/{abha_id}`
Fetches patient profile by ABHA ID.

**Response:**
```json
{
  "status": "success",
  "data": {
    "name": "Ramesh Kumar",
    "age": 55,
    "gender": "Male",
    "blood_group": "O+",
    "chronic_conditions": ["Diabetes Type 2", "Hypertension"],
    "allergies": ["Sulfa Drugs", "Penicillin"]
  }
}
```

---

### `POST /generate_scribe`
Converts a patient transcript into a structured medical HPI report.

**Request:**
```json
{
  "transcript": "I have had a fever for 3 days with a dry cough and body ache.",
  "language": "English",
  "patient_history": { "name": "Ramesh Kumar", "age": 55 }
}
```

**Response:**
```json
{
  "status": "success",
  "scribe_report": "**Chief Complaint (CC):** Fever for 3 days with dry cough and body ache.\n\n**History of Present Illness (HPI):** ..."
}
```

---

## 🚨 Severity Levels

| Level | Meaning | Actions Triggered |
| :--- | :--- | :--- |
| 🔴 RED | Emergency — immediate medical attention needed | Find Hospital, Call 108, Alert Family, Doctor Handover Card |
| 🟡 YELLOW | Moderate — consult a doctor soon | Find Hospital, Call 108, Alert Family, Doctor Handover Card |
| 🟢 GREEN | Mild — home care / OPD visit | Advice only |

---

## 📁 Project Structure

```
swasthya_ai/
├── swasthya_ai_backend/
│   ├── main.py           # FastAPI app — triage, ABHA, scribe endpoints
│   ├── seed_data.py      # Pinecone vector DB seeding script
│   ├── requirements.txt
│   └── .env
└── swasthya_ai_app/
    └── lib/
        ├── main.dart
        ├── features/
        │   ├── home_screen.dart      # Symptom input + voice
        │   ├── result_screen.dart    # Triage result + emergency actions
        │   ├── history_screen.dart   # Local medical ledger
        │   ├── abha_screen.dart      # ABHA ID lookup
        │   ├── consult_screen.dart   # AI Medical Scribe
        │   ├── profile_screen.dart   # Patient profile view
        │   └── main_layout.dart      # Bottom nav layout
        ├── models/
        │   └── triage_model.dart
        └── services/
            └── api_service.dart      # All API calls (triage, ABHA, scribe)
```

---

## ⚠️ Disclaimer

SwasthyaAI is an AI-assisted triage tool based on verified medical protocols. It is **not a substitute for professional medical diagnosis**. Always consult a qualified doctor for definitive medical advice.
