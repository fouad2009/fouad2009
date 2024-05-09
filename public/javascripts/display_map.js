function displayMap(mapId,info, latitude, longitude) {
  var map = L.map(mapId).setView([latitude, longitude], 13);

  var imageUrl = 'https://server.arcgisonline.com/ArcGIS/rest/services/World_Imagery/MapServer/tile/{z}/{y}/{x}';
  var arcgisLayer = L.tileLayer(imageUrl, {
    attribution: '© Esri'
  }).addTo(map);

  var marker = L.marker([latitude, longitude]).addTo(map);

  marker.bindPopup(info).openPopup();
}