# let nock intercept the request we made
# this allows us to use the full power of nock to respond the way we want
nock = require "nock"
fs = require "fs"

scopes = {}
for verb in ["GET", "POST", "PUT", "DELETE"]
  scopes[verb] = nock("http://localhost")
  .persist()
  .filteringPath((path) ->
      "/matchall"
    )
  .intercept("/matchall", verb)

module.exports = (req, res) ->
  file = "#{__dirname}#{req.url}/#{req.method}.json"
  if fs.existsSync file
    scopes[req.method].replyWithFile 200, file,
      "Content-Type": "application/json"
      "Access-Control-Allow-Origin": "*"
  else
    scopes[req.method].reply 404, "404 Not Found"