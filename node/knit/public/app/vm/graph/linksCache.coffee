define ->

  #one for all app, contains links from bit.ly vs title

  class LinksCache

    constructor: ->
      @links = []

    getTitles: (links) ->
      async.map links(),
        (link, ck) =>
          @getTitle link.href(), ck
        , (err, res) ->
          #links res
          l.title res[i] for l, i in links()
          console.log "get titles done"

    getTitle: (link, done) ->
      if /^(http:\/\/)?bit.ly\/\w+$/.test(link)
        t = @links[link]
        if !t
          @_req link, (err, title) =>
            @links[link] = title
            done err, title
        else
          done null, t

    _req: (link, done) ->
      key = "12b0031480e55c61cd57bf97026ea94ec1f0a85e"
      $.ajax
        url: "https://api-ssl.bitly.com/v3/link/info"
        data: link: link, access_token : key
        dataType:"jsonp"
        success: (data) ->
          if data.data
            done null, if data.data.html_title then data.data.html_title else (if data.data.canonical_url then data.data.canonical_url else link)
          else
            done null, link
        error: ->
          done null, link


  return new LinksCache()
  ###
  constructor: (bitlyLinks) ->
    @links = []
    @links[l] = l for l in bitlyLinks
    @_updateLinkTitles()

  getLink: (bitlyLink) ->
    @links[bitlyLink]

  _updateLinkTitles: ->
    async.forEach @links, ((linkTitle, ck) => @_updateLinkTitle(linkTitle, ck)), (err) ->
      console.log "links updated " + err

  _updateLinkTitle: (linkTitle, done) ->
    username = "baio1980"
    key = "12b0031480e55c61cd57bf97026ea94ec1f0a85e"
    $.ajax
        url: "http://api.bit.ly/v3/link/info"
        data: link:linkTitle, apiKey:key, login:username
        dataType:"jsonp"
        success: (data) ->
          console.log data
          done()
        error: ->
  ###
