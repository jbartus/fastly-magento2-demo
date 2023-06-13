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