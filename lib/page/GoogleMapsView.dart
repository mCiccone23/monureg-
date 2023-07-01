import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class GoogleMapWidget extends StatelessWidget {
  final double lat;
  final double lng;

  const GoogleMapWidget({required this.lat, required this.lng});

  @override
  Widget build(BuildContext context) {
    String htmlContent = '''
      <!DOCTYPE html>
      <html>
        <head>
          <meta name="viewport" content="initial-scale=1.0, user-scalable=no" />
          <style type="text/css">
            html, body { height: 100%; margin: 0; padding: 0; }
            #map { height: 100%; }
          </style>
          <script type="text/javascript">
            function initMap() {
              var latLng = new google.maps.LatLng($lat, $lng);
              var mapOptions = {
                center: latLng,
                zoom: 12
              };
              var map = new google.maps.Map(document.getElementById("map"), mapOptions);

              // Aggiungi il marker per la posizione attuale
              var currentLocationMarker = new google.maps.Marker({
                position: latLng,
                map: map,
                title: "Posizione attuale"
              });
            }
          </script>
          <script async defer
            src="https://maps.googleapis.com/maps/api/js?key=YOUR_API_KEY&callback=initMap">
          </script>
        </head>
        <body>
          <div id="map"></div>
        </body>
      </html>
    ''';

    return WebView(
      initialUrl: Uri.dataFromString(htmlContent, mimeType: 'text/html').toString(),
      javascriptMode: JavascriptMode.unrestricted,
    );
  }
}