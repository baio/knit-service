politic = require "./pedia-politic-rus-2-es-person-names"
org = require "./pedia-org-rus-2-es-org-names"

_ES_URI = process.env.ES_URI

###
politic.convert _ES_URI, (err) ->
  console.log "politic : ", err
###

org.convert _ES_URI, (err) ->
  console.log "org : ", err