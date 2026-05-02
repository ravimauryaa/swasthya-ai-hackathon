# 🏥 SwasthyaAI: Intelligent Medical Triage System

**SwasthyaAI** ek AI-powered diagnostic and triage solution hai jo users ko unke symptoms ke basis par real-time medical advice aur severity assessments provide karta hai. Iska goal emergency cases (RED) aur general symptoms (GREEN) ke beech ka gap kam karna hai.

---

## 🚀 Key Features

*   **Smart Triage Engine**: Gemini 2.5 Flash ka use karke symptoms ko RED, YELLOW, aur GREEN categories mein classify karta hai.
*   **Agentic RAG Architecture**: Pinecone Vector Database aur `all-mpnet-base-v2` embeddings ka use karke verified medical guidelines fetch karta hai.
*   **Multilingual Support**: App aur Backend dono Hinglish/Hindi support karte hain taaki common users ko samajhne mein aasani ho.
*   **High-Speed Local Hosting**: Latency kam karne ke liye server ko Mac M1 par local network par host kiya gaya hai.

---

## 🏗️ System Architecture

1.  **User Input**: User symptoms aur preferred language select karta hai.
2.  **Vector Search**: Backend (FastAPI) user input ko embed karke Pinecone se relevant verified medical data nikalta hai.
3.  **AI Reasoning**: Gemini AI fetch kiye gaye data aur symptoms ko combine karke final advice generate karta hai.
4.  **Mobile Output**: Flutter app JSON response ko decode karke visual alert (Red/Yellow/Green) show karti hai.

---

## 🛠️ Tech Stack

| Layer | Technology |
| :--- | :--- |
| **Mobile Frontend** | Flutter (Dart) |
| **API Backend** | FastAPI (Python) |
| **AI Models** | Google Gemini 2.5 Flash, Sentence-Transformers |
| **Vector DB** | Pinecone |
| **DevOps** | Local Server (Uvicorn), Git/GitHub |

---

## 💻 Installation & Setup

### Backend (swasthya_ai_backend)
1. Environment variables set karein (`.env` file):
   ```env
   GEMINI_API_KEY=YOUR_KEY
   PINECONE_API_KEY=YOUR_KEY