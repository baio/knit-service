es = require "./es/es"
_ES_URI = "http://188.244.44.9:9201"


backup = ->
  es.bkp _ES_URI, "org-names", "person-names.bkp", (err) -> console.log "person-names: " + err
  es.bkp _ES_URI, "org-names", "org-names.bkp", (err) -> console.log "org-names: " + err
  #es.copy _ES_URI, "org-names", "org-names.bkp", (err) -> console.log "org-names: " + err
  #es.copy _ES_URI, "predicates", "predicates.bkp", (err) -> console.log "predicates: " + err

backup()