define ->

  #update every 3 hours
  TTL = 1000 * 60 * 60 * 3

  _default_ref = "518b989739ed9714289d0bc1"

  _getName: (ref) ->
    ref = _default_ref if !ref
    "graph_" + ref

  _auth: ->
    true

  get: (filter) ->
    if filter.context != "data"
      console.log "get graph cache : " + @_getName filter.graph
      d = $.jStorage.get @_getName filter.graph
      if d then JSON.parse(d) else null

  update: (method, req_data, res_data) ->
    if method == "get"
      if !req_data or req_data.context != "data"
        #cache only if this is not graph of the user
        console.log "update graph cache : " + res_data.id
        _data = JSON.stringify(res_data)
        $.jStorage.set(@_getName(res_data.id), _data, {TTL: TTL})
    else
      console.log "swap user after any NOT PUT graph update"
      $.jStorage.deleteKey "curUser"
      ref = req_data.graph
      ref ?= req_data.id
      ref ?= req_data.ref
      console.log "swap graph after any graph update #{ref}"
      $.jStorage.deleteKey @_getName(ref)

