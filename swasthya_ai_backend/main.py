from fastapi import FastAPI, HTTPException
from pydantic import BaseModel
from typing import Optional, Dict, Any
import google.generativeai as genai
import os
from dotenv import load_dotenv
from pinecone import Pinecone
from sentence_transformers import SentenceTransformer
import json

# Load .env for API Keys
load_dotenv()

app = FastAPI(title="SwasthyaAI Local Pro Backend")

# Setup Gemini
genai.configure(api_key=os.getenv("GEMINI_API_KEY"))
model = genai.GenerativeModel('gemini-2.5-flash')

# Setup Pinecone Local Embedding Model
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
        
        # AGENT 1: Local Vector Search
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

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000)