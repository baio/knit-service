define ["app/config", "app/cache/manager"], (config, cache) ->

  class DataProvider

    onGetBaseUrl: -> config.base_url

    onFlatData: (data) ->
      for own prop of data
        if !(data[prop] instanceof Date) and (typeof data[prop] == "object" or Array.isArray(data[prop]) or $.isFunction(data[prop]))
          delete data[prop]
      @date2json data
      data

    parseDate: (str) ->
      dt = moment(str, "YYYY-MM-DDTHH:mm:ss.Z")
      if dt and dt.isValid()
        dt.toDate()
      else
        undefined

    formatDate: (obj) ->
      obj.toUTCString()

    date2json: (data) ->
      #though in this instance object is flat in derived it could be not, so recursive
      for own prop of data
        if data[prop] instanceof Date
          data[prop] = formatDate(data[prop])
        else if typeof data[prop] == "object"
          @date2json data[prop]
        else if Array.isArray data[prop]
          @date2json d for d in data[prop]

    undef2null: (data) ->
      for own prop of data
        if data[prop] is undefined
          data[prop] = null
        else if typeof data[prop] == "object"
          @undef2null data[prop]
        else if Array.isArray data[prop]
          @undef2null d for d in data[prop]

    json2date: (data) ->
      #though in this instance object is flat in derived it could be not, so recursive
      for own prop of data
        if typeof data[prop] == "string"
          dt = @parseDate data[prop]
          data[prop] = dt if dt
        else if Array.isArray data[prop]
          for d in data[prop]
            @json2date d
        else if typeof data[prop] == "object"
          @json2date data[prop]

    onGetUrl: (resource, action) ->
      if action
        res = "/#{resource}/#{action}"
      else
        res = "/#{resource}"

      @onGetBaseUrl() + res

    onGetError: (resp, res) ->
      if res == "error"
        code : resp.status, message : resp.statusText
      else if resp.errors or resp.error
        code : 500, message : (if resp.error then resp.error else "Error"), errors : resp.errors

    get: (resource, filter, done) ->
      @ajax resource, "get", filter, done
      ###
      $.get(@onGetUrl(resource), filter)
        .always (resp, res) =>
          err = @onGetError(resp, res)
          if !err
            @json2date resp
          done err, resp
      ###

    update: (resource, data, done) ->
      @date2json(data)
      $.post(@onGetUrl(resource), JSON.stringify(data))
        .always (resp, res) =>
          err = @onGetError(resp, res)
          if !err
            @json2date resp
          done err, resp

    create: (resource, data, done) ->
      @date2json(data)
      $.post(@onGetUrl(resource), JSON.stringify(data))
        .always (resp, res) =>
          err = @onGetError(resp, res)
          if !err
            @json2date resp
          done err, resp

    ajax: (resource, method, data, done) ->
      if method == "get"
        c = @_cache_get(resource, data)
        if c
          done null, c
          return
      d = data
      if data and !$.isEmptyObject(data)
        if method == "get"
          @onFlatData(data)
        else
          @undef2null(@json2date data)
          data = JSON.stringify(data)
      else
        data = undefined
      $.ajax(
        url: @onGetUrl(resource)
        data: data
        method : method
        crossDomain : true
        contentType : "application/json; charset=UTF-8"
        dataType : 'json'
      ).always (resp, res) =>
          err = @onGetError(resp, res)
          if !err
            @json2date resp
            @_cache_upd resource, method, d, resp
          done err, resp

    _cache_get: (resource, filter) ->
      c = cache resource
      if c then c.get filter else null

    _cache_upd: (resource, method, req_data, res_data) ->
      c = cache resource
      if c then c.update method, req_data, res_data

  new DataProvider()