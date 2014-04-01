# let nock intercept the request we made
# this allows us to use the full power of nock to respond the way we want
# see https://github.com/flatiron/nock for documentation
nock = require "nock"
fs = require "fs"
url = require "url"

scopes = {}
for verb in ["GET", "POST", "PUT", "DELETE", "OPTIONS"]
  scopes[verb] = nock("http://localhost")
  .defaultReplyHeaders(
      "Content-Type": "text/plain"
      "Access-Control-Allow-Origin": "*"
      "Access-Control-Allow-Methods": "POST, GET, PUT, DELETE, OPTIONS"
      "Access-Control-Allow-Headers": "Origin, X-Requested-With, Content-Type, Accept"
      "X-Powered-By": "Nock"
    )
  .persist()
  .filteringPath((path) ->
      "/matchall"
    )
  .intercept("/matchall", verb)

module.exports = (req, res) ->
  if req.method is "OPTIONS"
    return scopes[req.method].reply 200, "200 OK"

  urlPieces = url.parse req.url, true

  filePatterns = [
    "#{__dirname}#{urlPieces.pathname}/#{req.method}#{urlPieces.search}.json"
    "#{__dirname}#{urlPieces.pathname}/#{req.method}.json"
  ]

  for file in filePatterns
    console.log "Looking for file #{file}"
    if fs.existsSync file
      returnFile = file
      break

  if returnFile?
    console.log "Serving file #{returnFile}"
    scopes[req.method].replyWithFile 200, returnFile,
      "Content-Type": "application/json"
  else
    scopes[req.method].reply 404, "404 Not Found"
