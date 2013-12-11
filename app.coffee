httpProxy = require "http-proxy"

port = process.argv[3] or 8080 # port to listen to; on OS X, sudo is required to listen to port 80
host = "localhost"
nock_setup_file = process.argv[2] or "nock-sample.coffee"

# try to include the custom nock usage file specified as the first argument in the command line
try
  nock_setup = require nock_setup_file
catch e
  console.log "There was an error while loading the nock setup file at path #{nock_setup_file}\n", e
  process.exit 1

# create a proxy server that will receive requests and send them again for nock to intercept
httpProxy.createServer((req, res, proxy) ->
  # call the exortable function from our nock file to give it res and req variables
  # this allows us to change the response depending on the request
  # e.g. send a different json file based on the url path
  nock_setup req, res

  # send request again, this time on port 80
  proxy.proxyRequest(req, res, {host, port: 80})
).listen port

console.log "Listening for requests at #{host}:#{port}"