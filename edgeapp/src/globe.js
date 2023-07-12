const markerSvg = `<svg viewBox="-4 0 36 36">
  <path fill="currentColor" d="M14,0 C21.732,0 28,5.641 28,12.6 C28,23.963 14,36 14,36 C14,36 0,24.064 0,12.6 C0,5.641 6.268,0 14,0 Z"></path>
  <circle fill="black" cx="14" cy="14" r="7"></circle>
  </svg>`;

const myGlobe = Globe()
    .globeImageUrl('//unpkg.com/three-globe/example/img/earth-dark.jpg')

myGlobe(document.getElementById('globe'))

fetch('/geoip')
    .then((response) => response.json())
    .then(data => {
        myGlobe
            .pointOfView({ lat: data.geo.latitude, lng: data.geo.longitude, altitude: 0.5 })
            .htmlElementsData([{"lat": data.geo.latitude, "lng": data.geo.longitude}])
            .htmlElement(d => {
                const el = document.createElement('div');
                el.innerHTML = markerSvg;
                el.style.color = "red";
                el.style.width = "30px";
                return el;
            })
    })

fetch('/pops')
    .then((response) => response.json())
    .then(data => {
        myGlobe
            .labelsData(data)
            .labelLat(d => d.latitude)
            .labelLng(d => d.longitude)
            .labelText(d => d.code)
    })

// FIXME draw an arc from your geolocation to the nearest pop (serving pop), labeled with the geo.as.name