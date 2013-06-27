define ->

  get: ->
    null

  update: (method, req_data, res_data) ->
    console.log "curUser", method, req_data, res_data
    if method == "patch"
      #swap all graphs!
      console.log "when contrib patched, swap all graphs!"
      for i in $.jStorage.index()
        if i.indexOf("graph_") == 0
          $.jStorage.deleteKey i