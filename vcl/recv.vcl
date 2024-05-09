# enable image optimization
if(req.url.ext ~ "(?i)^(gif|png|jpe?g|webp)$") {
	set req.http.x-fastly-imageopto-api = "fastly";
}