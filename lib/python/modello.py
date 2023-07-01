from pymongo import MongoClient
from skimage import io
from io import BytesIO
import numpy as np
from skimage.transform import resize
from sklearn.preprocessing import normalize
from sklearn.base import BaseEstimator, TransformerMixin
from skimage.color import rgb2gray
from PIL import Image
from river.tree import HoeffdingTreeClassifier
from river.preprocessing import StandardScaler

# Connessione al database MongoDB
client = MongoClient('mongodb://localhost:27017')
db = client['monureg']
collection = db['mon_images']

class ImagePreprocessor(BaseEstimator, TransformerMixin):
    def __init__(self, target_size=(32, 32)):
        self.target_size = target_size
        
    def fit(self, X, y=None):
        return self
    
    def transform(self, X):
        processed_images = []
        
        for image in X:
            # Ridimensionamento dell'immagine
            resized_image = resize(image, self.target_size)
            
            # Conversione in scala di grigi
            gray_image = rgb2gray(resized_image)
            
            # Normalizzazione dei valori dei pixel
            normalized_image = normalize(gray_image)
            
            processed_images.append(normalized_image)
            
        return np.array(processed_images)


images = []
labels = []

# Iterazione sui documenti nella collection "mon_images"
for document in collection.find():
    # Recupero dell'immagine binData e dell'etichetta dal documento
    image_bin = document['image']
    label = document['monument_name']
    
    # Caricamento dell'immagine utilizzando skimage
    image_data = BytesIO(image_bin)
    image = Image.open(image_data)

    images.append(image)
    labels.append(label)


processor = ImagePreprocessor(target_size=(64, 64))
preprocessed_images = processor.transform(images)

scaler = StandardScaler()
preprocessed_images = scaler.fit_transform(preprocessed_images)

classifier = HoeffdingTreeClassifier()
for image, label in zip(preprocessed_images, labels):
    classifier.learn_one(image, label)
    
   