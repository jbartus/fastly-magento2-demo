# an example of a json synthetic response
if (obj.status == 600 ) {
  synthetic {"{
    "as": {
      "name": ""} json.escape(client.as.name) {""
    },
    "geo": {
      "city": ""} json.escape(client.geo.city) {"",
      "latitude": ""} json.escape(client.geo.latitude) {"",
      "longitude": ""} json.escape(client.geo.longitude) {""
    }
  }"};
  set obj.status = 200;
  set obj.response = "OK";
  set obj.http.Content-Type = "application/json";
  return (deliver);
}