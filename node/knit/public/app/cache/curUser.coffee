define ->

  get: ->
    if $.jStorage.get "app_reload"
      $.jStorage.deleteKey "app_reload"
      return null
    else
      return $.jStorage.get "curUser"

  update: (method, req_data, res_data) ->
    console.log "curUser", method, req_data, res_data
    if method == "get"
      stored_user = $.jStorage.get "curUser"
      if !stored_user or stored_user._id != res_data._id
        console.log "new user, swap cache [was #{stored_user}, become #{res_data._id}]"
        $.jStorage.flush()
      #even if this is the same user update one, since it could be changed after app reload
      $.jStorage.set "curUser", res_data

