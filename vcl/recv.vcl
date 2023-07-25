if(fastly.ff.visits_this_service == 0 && ratelimit.check_rate(client.ip, demo_rc, 1, 10, 200, demo_pb, 1m)){
  error 429 "Too Many Requests";
}

if(req.method == "GET"){
  if(req.url.path == "/geo" ) {
    error 600;
  }
  if(req.url.path == "/favicon.ico"){
    error 601;
  }
}

if(req.url ~ "/pass"){
  return(pass);
}

if(querystring.get(req.url, "io") && req.url.ext ~ "(?i)^(gif|png|jpe?g|webp)$") {
	set req.http.x-fastly-imageopto-api = "fastly";
}