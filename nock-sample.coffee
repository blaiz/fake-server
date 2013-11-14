nock = require "nock"

# let nock intercept the request we made
# this allows us to use the full power of nock to respond the way we want
scopeGet = nock("http://localhost")
.persist()
.filteringPath((path) ->
    "/matchall"
  )
.intercept("/matchall", "GET")

scopePost = nock("http://localhost")
.persist()
.filteringPath((path) ->
    "/matchall"
  )
.intercept("/matchall", "POST")

module.exports = (req, res) ->
  scopeGet.replyWithFile 200, "#{req.url.substr 1}.json"
  scopePost.replyWithFile 200, "#{req.url.substr 1}.json"