define ["app/vm/graph/linksCache"], (linksCache) ->

  class Toolbox

    constructor: (@nav, @panel)->
      @name_src = ko.observable()
      @name_tgt = ko.observable()
      @tags = ko.observableArray()
      @url_src = ko.computed => "https://www.google.ru/search?q=#{@name_src()}"
      @url_tgt = ko.computed => "https://www.google.ru/search?q=#{@name_tgt()}"
      @panel.onHoverEdge = (edge) =>
        @name_src edge.source.name
        @name_tgt edge.target.name
        _t = []
        for tag in edge.tags
          _u = tag.urls.map (m) -> href : ko.observable(m), title : ko.observable(m)
          _t.push( name : ko.observable(tag.val), urls : ko.observableArray(_u))
        @tags _t
      @panel.onDblClickSvg = ->
        pos = d3.mouse(@)
        offset = $("#_body").offset()
        x = pos[0] - $(document).scrollLeft() - offset.left
        y = pos[1] - $(document).scrollTop() - offset.top
        $("#_toolbox").css(left : x, top: y)
        _this.isShown true

      @isShown = ko.observable(false)

    moveToConner: (data, event) ->
      event.preventDefault()
      $("#_toolbox").css(left : '', top: '')

    hide: ->
      @isShown false

    show: ->
      @isShown true

    linksShown: (data, event) ->
      console.log "links shown"
      linksCache.getTitles data.urls