import os
from google.cloud import vision
from google_vision_ai import GLClassifier, VisionAI, get_closest_place
from google_vision_ai import prepare_image_local, prepare_image_web, draw_boundary, draw_boundary_normalized, web_scraping_wikipedia
import json
from google.protobuf.json_format import MessageToJson
import proto
import pymongo
from pymongo.mongo_client import MongoClient
from pymongo.server_api import ServerApi
# URL di connessione al database MongoDB

from pymongo.mongo_client import MongoClient
from pymongo.server_api import ServerApi
import urllib.request
from io import BytesIO
import urllib3
from PIL import Image
import requests

# Create a new client and connect to the server
client = MongoClient('mongodb://127.0.0.1/27017')

database = client['monureg']
# Send a ping to confirm a successful connection
try:
    client.admin.command('ping')
    print("Pinged your deployment. You successfully connected to MongoDB!")
except Exception as e:
    print(e)

api_key = 'AIzaSyBcJWVfG4CAf8LV298KAbacKrN4R38nzd4'
os.environ['GOOGLE_APPLICATION_CREDENTIALS'] = '/Users/matteociccone/Downloads/prova/vision/bin/vision_credential.json'
image = 'https://upload.wikimedia.org/wikipedia/commons/c/c8/Petruzzellibarioggi.jpg'
lat = 41.126514
lon = 16.872627

risultato  = GLClassifier(image, lat, lon)
if risultato:
    nome = risultato[0]
    latitudine = risultato[1]
    longitudine = risultato[2]
else:
    image_data = prepare_image_web(image)
    
    client = vision.ImageAnnotatorClient()
    va = VisionAI(client, image_data)
    landmarks = va.landmark_detection()
    serialized = proto.Message.to_json(landmarks) 
    json_data = json.loads(serialized)
    if not 'error' in json_data: 
        nome = json_data['landmarkAnnotations'][0]['description']
        latitudine = json_data['landmarkAnnotations'][0]['locations'][0]['latLng']['latitude']
        longitudine = json_data['landmarkAnnotations'][0]['locations'][0]['latLng']['longitude']
    elif 'error' in landmarks:
        closest_place = get_closest_place(lat,lon, api_key)
        if closest_place:
            nome = closest_place['name']
            latitudine = closest_place['geometry']['location']['lat']
            longitudine = closest_place['geometry']['location']['lng']

collection = database["monuments"]

name_to_search = nome
query = {"nome": name_to_search}
result = collection.find_one(query)
    
if not result:
    desc = web_scraping_wikipedia(nome)
else:
    desc = result['descrizione']

# Accedi alla collezione "monuments"
monumento = {
    "nome": nome,
    "descrizione": desc,
    "latitudine": latitudine,
    "longitudine": longitudine,
}
if not result:
    collection.insert_one(monumento)
if desc:
    response = requests.get(image)
    img = Image.open(BytesIO(response.content))
    binary_stream = BytesIO()
    img.save(binary_stream, format="JPEG")
    binary_data = binary_stream.getvalue()
    collection = database['mon_images']
    image_id = collection.insert_one({'image': binary_data, 'monument_name': nome}).inserted_id



print(monumento['nome'])
print(monumento['descrizione'])
