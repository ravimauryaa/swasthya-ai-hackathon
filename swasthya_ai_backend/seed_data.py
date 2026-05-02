import os
from pinecone import Pinecone
from sentence_transformers import SentenceTransformer
from dotenv import load_dotenv

load_dotenv()

# Setup
pc = Pinecone(api_key=os.getenv("PINECONE_API_KEY"))
index = pc.Index("swasthya-db")
# Dim 768 ke liye ye model best hai
model = SentenceTransformer('all-mpnet-base-v2') 

# Verified Medical Guidelines (WHO/MoHFW standard based)
medical_data = [
    {"id": "1", "text": "Chest pain, shortness of breath, and left arm pain are signs of a heart attack. Action: RED ALERT, Call Emergency immediately."},
    {"id": "2", "text": "Persistent high fever over 103F with cough could be pneumonia. Action: YELLOW ALERT, Visit a clinic within 24 hours."},
    {"id": "3", "text": "Mild headache and runny nose without fever are signs of common cold. Action: GREEN ALERT, Home care and rest."},
    {"id": "4", "text": "Severe bleeding or deep puncture wounds require immediate pressure and ER visit. Action: RED ALERT, SOS."},
]

print("Processing data for RAG...")

for item in medical_data:
    # Text ko vector (embedding) mein badalna
    vector = model.encode(item['text']).tolist()
    # Pinecone mein save karna
    index.upsert(vectors=[{"id": item['id'], "values": vector, "metadata": {"text": item['text']}}])

print("✅ Data successfully pushed to Pinecone! Your RAG is now grounded.")