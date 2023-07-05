from flask import Flask, request, jsonify, send_from_directory
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
import datetime
import shutil
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


@app.route('/vision/landmarks', methods=['POST'])
def landmarks():
    data = request.json
    image = data['image']
    lat = data['latitudine']
    lon = data['longitudine']
    tipo = data['tipo']
    nome = ' '
    latitudine = 0
    longitudine = 0
    if tipo == 1:

        risultato  = GLClassifier(image, lat, lon)
        if risultato:
            nome = risultato[0]
            latitudine = risultato[1]
            longitudine = risultato[2]
        else:
            image_data = prepare_image_local(image)
            
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
                return Exception



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

            del monumento['_id']

        if desc:
            ora_corrente = datetime.datetime.now().strftime("%H-%M-%S")
            estensione = os.path.splitext(image)[1]
            if not os.path.exists(f"/Users/matteociccone/Desktop/casodistudio/files/{nome}"):
                os.makedirs(f"/Users/matteociccone/Desktop/casodistudio/files/{nome}")
            
            filePath = f"/Users/matteociccone/Desktop/casodistudio/files/{nome}/{ora_corrente}.{estensione}"
            shutil.move(image,filePath)
            
            collection = database['mon_images']
            image_id = collection.insert_one({'image': filePath, 'monument_name': nome}).inserted_id
    else:
        cp = get_closest_place(lat,lon, api_key)
        collection = database["monuments"]
        query = {"nome": cp['name']}
        result = collection.find_one(query)

        if result == None:
            desc = web_scraping_wikipedia(nome, 1)
            if not desc:
                desc = web_scraping_wikipedia(nome, 0)
            if not desc:
                desc = web_scraping_wikipedia(cp['name'], 0)
        else:
            desc = result['descrizione']

        # Accedi alla collezione "monuments"
        monumento = {
            "nome": cp['name'],
            "descrizione": desc,
            "latitudine": cp['geometry']['location']['lat'],
            "longitudine": cp['geometry']['location']['lng'],
        }

    jsonMonu = json.dumps(monumento)
    return jsonMonu


@app.route('/files/input/<filename>')
def get_file(filename):
    file_dir = '/Users/matteociccone/Desktop/casodistudio/files/input'
    return send_from_directory(file_dir, filename)

@app.route('/upload', methods=['POST'])
def upload_file():
    file = request.files['file']
    file.save(os.path.join('/Users/matteociccone/Desktop/casodistudio/files/input', file.filename))
    file_path = f"/Users/matteociccone/Desktop/casodistudio/files/input/{file.filename}"  #Costruisci il percorso completo del file
    return jsonify({'file_path': file_path})

@app.route('/upload_label', methods=['POST'])
def upload_label():
    file = request.files['file']
    file.save(os.path.join('/Users/matteociccone/Desktop/casodistudio/files/input', file.filename))
    file_path = f"http://192.168.1.56:105/files/input/{file.filename}"  #Costruisci il percorso completo del file
    return jsonify({'file_path': file_path})  

@app.route('/list')
def list_files():
    files = os.listdir('files/')
    return {'files': files}
@app.route('/upload_report', methods=['POST'])

def upload_report():
    data = request.json
    email = data['email']
    city = data['city']
    monument = data['monument']
    note = data['note']

    report = {
        'email' : email,
        'city' : city,
        'monument' : monument,
        'note' : note,
    }

    collection = database["reports"]
    collection.insert_one(report).inserted_id
    report = {
        'email' : email,
        'city' : city,
        'monument' : monument,
        'note' : note,
    }
    return json.dumps(report)

if __name__ == '__main__':
   app.run(host='0.0.0.0', port=105)
