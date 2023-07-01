function landmarkDetection(_image){
    const fs = require('fs');
const vision = require('@google-cloud/vision');

const credentialsFile = './vision_credential.json';
const credentials = JSON.parse(fs.readFileSync(credentialsFile));
// Crea un cliente per le API di Google Vision
const client = new vision.ImageAnnotatorClient({
  keyFilename: credentialsFile,
  projectId: credentials.project_id,
});

// Carica l'immagine da analizzare
const imageFile = '/Users/matteociccone/Downloads/prova/PalazzoMincuzzi.jpg';
const image = fs.readFileSync(imageFile);
const encodedImage = Buffer.from(image).toString('base64');

// Configura la richiesta
const request = {
  image: { content: encodedImage },
  features: [{ type: 'LANDMARK_DETECTION' }]
};

// Invia la richiesta alle API di Google Vision
client
  .annotateImage(request)
  .then(response => {
    const landmarks = response[0].landmarkAnnotations;
    console.log('Punti di riferimento trovati:');
    landmarks.forEach(landmark => {
      console.log(`Nome: ${landmark.description}`);
      console.log(`Posizione: (${landmark.locations[0].latLng.latitude}, ${landmark.locations[0].latLng.longitude})`);
      console.log('----------------');
    });
  })
  .catch(err => {
    console.error('Errore durante l\'analisi dell\'immagine:', err);
  });

  return landmarks;
}