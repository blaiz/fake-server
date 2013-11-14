# let nock intercept the request we made
# this allows us to use the full power of nock to respond the way we want
nock = require "nock"

scopes = {}
for verb in ["GET", "POST", "PUT", "DELETE"]
  scopes[verb] = nock("http://localhost")
  .persist()
  .filteringPath((path) ->
      "/matchall"
    )
  .intercept("/matchall", verb)

module.exports = (req, res) ->
  scopes[req.method].replyWithFile 200,
    "#{__dirname}#{req.url}/#{req.method}.json",
    {"Content-Type": "application/json"}