from flask import Flask, request, jsonify
import os
from google.cloud import vision
from google_vision_ai import VisionAI
from google_vision_ai import prepare_image_local, prepare_image_web, draw_boundary, draw_boundary_normalized,web_scraping_wikipedia,get_closest_place, GLClassifier
import json
from google.protobuf.json_format import MessageToJson
import proto
import pymongo
import json
from pymongo.mongo_client import MongoClient
from pymongo.server_api import ServerApi
import requests
from PIL import Image
from io import BytesIO
uri = "mongodb+srv://mathew23s:mathew23s@cluster0.hqtpku6.mongodb.net/?retryWrites=true&w=majority"
# Create a new client and connect to the server
client = MongoClient('mongodb://127.0.0.1/27017')

database = client['monureg']
# Send a ping to confirm a successful connection
try:
    client.admin.command('ping')
    print("Pinged your deployment. You successfully connected to MongoDB!")
except Exception as e:
    print(e)



os.environ['GOOGLE_APPLICATION_CREDENTIALS'] = '/Users/matteociccone/Desktop/casodistudio/monureg/lib/python/visual-credential.json'
api_key = 'AIzaSyBMKW_Sa0VGRwsSFQNV5uURtVz7dw_bOpU'
app = Flask(__name__)


@app.route('/vision/position', methods=['POST'])
def landmarks():
    data = request.json
    image = data['image']
    lat = data['latitudine']
    lon = data['longitudine']
    nome = ' '
    latitudine = 0
    longitudine = 0
    
    cp = get_closest_place(lat,lon, api_key)
    collection = database["monuments"]
    name_to_search = nome
    query = {"nome": name_to_search}
    result = collection.find_one(query)
        
    if not result:
        desc = web_scraping_wikipedia(nome, 1)
        if not desc:
            desc = web_scraping_wikipedia(nome, 0)
        if not desc:
            desc = web_scraping_wikipedia(cp['name'], 0)
        if not desc:
            return Exception
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

    jsonMonu = json.dumps(monumento)
    return jsonMonu

if __name__ == '__main__':
   app.run(host='0.0.0.0', port=105)
