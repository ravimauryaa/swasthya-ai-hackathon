from fastapi import FastAPI, HTTPException
from pydantic import BaseModel
from typing import Optional, Dict, Any
import google.generativeai as genai
import os
from dotenv import load_dotenv
from pinecone import Pinecone
from sentence_transformers import SentenceTransformer
import json

# Load .env to API Keys
load_dotenv()

app = FastAPI(title="SwasthyaAI Local Pro Backend")

# ==========================================
# GEMINI SETUP (With Auto-Fixer for API Key)
# ==========================================
raw_api_key = os.getenv("GEMINI_API_KEY", "")
# Nayi key se extra spaces aur quotes hatane ka logic
clean_api_key = raw_api_key.strip().strip('"').strip("'") 

# Terminal me check karne ke liye ki key sahi load hui ya nahi (Starting ke 10 characters)
print(f"DEBUG - Meri Asli Key Yahan Se Shuru Hoti Hai: '{clean_api_key[:10]}...'") 

genai.configure(api_key=clean_api_key)
# Free tier ke liye sabse best aur fast model
model = genai.GenerativeModel('gemini-2.5-flash')

# ==========================================
# PINECONE & RAG SETUP
# ==========================================
pc = Pinecone(api_key=os.getenv("PINECONE_API_KEY"))
index = pc.Index("swasthya-db")
embedder = SentenceTransformer('all-mpnet-base-v2') 

# ==========================================
# PHASE 3: MOCK ABHA DATABASE & ENDPOINT
# ==========================================
MOCK_ABHA_DB = {
    "14-1111-2222-3333": {
        "name": "Ramesh Kumar",
        "age": 55,
        "gender": "Male",
        "blood_group": "O+",
        "chronic_conditions": ["Diabetes Type 2", "Hypertension"],
        "allergies": ["Sulfa Drugs", "Penicillin"]
    }
}

@app.get("/api/v1/abha/patient/{abha_id}")
async def get_patient_profile(abha_id: str):
    """Industry Standard Isolated Endpoint for ABHA Integration"""
    patient = MOCK_ABHA_DB.get(abha_id)
    if not patient:
        raise HTTPException(status_code=404, detail="Patient record not found")
    return {"status": "success", "data": patient}
# ==========================================

class SymptomInput(BaseModel):
    text: str
    language: str = "English"
    patient_history: Optional[Dict[str, Any]] = None # New parameter for ABHA context

@app.post("/api/triage")
async def triage_symptoms(user_input: SymptomInput):
    try:
        target_lang = user_input.language
        
        # AGENT 1: Local Vector Search (RAG)
        user_vector = embedder.encode(user_input.text).tolist()
        search_result = index.query(vector=user_vector, top_k=1, include_metadata=True)
        
        verified_guideline = "Standard medical triage protocol."
        if search_result.get("matches"):
            verified_guideline = search_result["matches"][0]["metadata"]["text"]

        # ABHA Context Injection (The Magic)
        history_context = ""
        if user_input.patient_history:
            history_context = f"\nCRITICAL PATIENT HISTORY: {json.dumps(user_input.patient_history)}\nKeep this medical history in mind to prevent adverse advice (e.g., allergies) and adjust severity accordingly."

        # AGENT 2: AI Reasoning & Translation
        prompt = f"""
        Analyze User Symptoms: '{user_input.text}'
        Based on Verified Guideline: '{verified_guideline}'{history_context}
        
        Task:
        1. Classify severity: RED, YELLOW, or GREEN.
        2. Provide actionable advice STRICTLY in {target_lang}.
        
        Respond ONLY in strict JSON format:
        {{"severity": "RED", "action": "translated advice"}}
        """
        
        response = model.generate_content(prompt)
        json_str = response.text.replace('```json', '').replace('```', '').strip()
        
        print(f"Symptom: {user_input.text} | History Linked: {bool(user_input.patient_history)}") 
        
        return {"status": "success", "ai_response": json.loads(json_str)}
        
    except Exception as e:
        print(f"Error: {e}")
        return {"status": "error", "ai_response": {"severity": "YELLOW", "action": "Local Server Error: " + str(e)}}


# ==========================================
# PHASE 6: CONSULTATION (AI SCRIBE) ENDPOINT
# ==========================================
class ScribeRequest(BaseModel):
    transcript: str
    language: str = "English"
    patient_history: Optional[Dict[str, Any]] = None

@app.post("/generate_scribe")
async def generate_medical_scribe(req: ScribeRequest):
    try:
        # Prompt Engineering: The AI Scribe Persona
        prompt = f"""
        You are an expert Clinical Medical Scribe. 
        Your job is to take a raw, unstructured transcript from a patient and convert it into a professional, structured History of Present Illness (HPI) report for a doctor.
        
        Patient Transcript: "{req.transcript}"
        Language Spoken: {req.language}
        Patient Profile Data: {req.patient_history}
        
        Generate the report strictly in this format:
        **Chief Complaint (CC):** (1 sentence summary)
        
        **History of Present Illness (HPI):** (Professional medical paragraph covering Onset, Location, Duration, Character, Aggravating/Alleviating factors if mentioned)
        
        **Key Symptoms:** (Bullet points)
        
        Keep it concise, professional, and ready for a doctor to read in 15 seconds. Do not invent details that the patient didn't mention.
        """
        
        # Using the globally defined Gemini 2.5 Flash model
        response = model.generate_content(prompt)
        
        return {
            "status": "success",
            "scribe_report": response.text.strip()
        }
    except Exception as e:
        return {"status": "error", "message": str(e)}

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000)