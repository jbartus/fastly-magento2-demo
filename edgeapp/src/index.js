import { env } from "fastly:env";
import { includeBytes } from "fastly:experimental";
import { SecretStore } from "fastly:secret-store";

const homePage = includeBytes("./src/index.html")
const globeJs = includeBytes("./src/globe.js")

addEventListener("fetch", (event) => event.respondWith(handleRequest(event)));

async function handleRequest(event) {

  console.log("FASTLY_SERVICE_VERSION:", env('FASTLY_SERVICE_VERSION') || 'local');

  const req = event.request;
  const url = new URL(req.url)

  if (url.pathname == "/") {
    return new Response(homePage, {
      status: 200,
      headers: new Headers({"Content-Type": "text/html; charset=utf-8"})
    })
  }

  if (url.pathname == "/globe.js") {
    return new Response(globeJs, {
      status: 200,
      headers: new Headers({"Content-Type": "application/javascript"})
    })
  }

  if (url.pathname == "/geoip") {
    const clientGeo = event.client.geo

    const respBody = JSON.stringify({
      as: {
        name: clientGeo.as_name,
      },
      geo: {
        city: clientGeo.city,
        latitude: clientGeo.latitude,
        longitude: clientGeo.longitude,
      },
    })

    return new Response(respBody, {
      headers: {
        "Content-Type": "application/json"
      }
    })
  }

  if (url.pathname == "/pops") {
    const secrets = new SecretStore('secrets')
    const fastlyApiKey = await secrets.get('fastly-key')
  
    const response = await fetch('https://api.fastly.com/datacenters', {
      backend: "fastlyapi",
      headers: {
        'Accept': 'application/json',
        'Fastly-Key': fastlyApiKey.plaintext()
      }
    })
    const data = await response.json();
    const filteredData = data.map(({code, coordinates: {latitude, longitude}}) => ({code, latitude, longitude}))
    return new Response(JSON.stringify(filteredData), { 
      headers: { 
        "Content-Type": "application/json" 
      }})
  }

  return new Response("OK", { status: 200 });
}