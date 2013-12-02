# let nock intercept the request we made
# this allows us to use the full power of nock to respond the way we want
# see https://github.com/flatiron/nock for documentation
nock = require "nock"
fs = require "fs"
url = require "url"

scopes = {}
for verb in ["GET", "POST", "PUT", "DELETE"]
  scopes[verb] = nock("http://localhost")
  .defaultReplyHeaders(
      "Content-Type": "text/plain"
      "Access-Control-Allow-Origin": "*"
      "X-Powered-By": "Nock"
    )
  .persist()
  .filteringPath((path) ->
      "/matchall"
    )
  .intercept("/matchall", verb)

module.exports = (req, res) ->
  urlPieces = url.parse req.url, true

  filePatterns = [
    "#{__dirname}#{urlPieces.pathname}/#{req.method}#{urlPieces.search}.json"
    "#{__dirname}#{urlPieces.pathname}/#{req.method}.json"
  ]

  for file in filePatterns
    if fs.existsSync file
      returnFile = file
      break

  if returnFile?
    console.log "Serving file #{returnFile}"
    scopes[req.method].replyWithFile 200, returnFile,
      "Content-Type": "application/json"
  else
    scopes[req.method].reply 404, "404 Not Found"