# synthetics piggy back on varnish error handling but arent errors to the user
if (resp.status == 600 ) {
  set resp.status = 200;
  set resp.response = "OK";
}

if (resp.status == 601 ) {
  set resp.status = 200;
  set resp.response = "OK";
}