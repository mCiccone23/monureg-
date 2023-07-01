import joblib
import numpy as np
from PIL import Image
import io
# Carica il classificatore addestrato
clf = joblib.load('model.pkl')

# Carica il preprocessor
preprocessor = joblib.load('preprocessor.pkl')

# Carica il label_encoder
label_encoder = joblib.load('label_encoder.pkl')

# Carica e preelabora l'immagine di input
image = '/Users/matteociccone/Desktop/petruzzelli/3.jpg'
img = Image.open(io.BytesIO(image))
image_array = np.array(image)
preprocessed_image = preprocessor.transform_one({'image': image_array})

# Classificazione
predicted_label_encoded = clf.predict_one(preprocessed_image)
predicted_label = label_encoder.inverse_transform([predicted_label_encoded])

# Stampa l'etichetta predetta
print("Etichetta predetta:", predicted_label)
