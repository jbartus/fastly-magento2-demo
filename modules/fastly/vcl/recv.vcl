if(req.method == "GET"){
  if(req.url.path == "/syn" ) {
    error 600;
  }
  if(req.url.path == "/favicon.ico"){
    error 601;
  }
}

if(req.url ~ "/pass"){
  return(pass);
}