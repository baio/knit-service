define [
        "ural/vm/itemVM"
        "app/dataProvider"
        "ural/modules/pubSub"
]
, (itemVM, dataProvider, pubSub) ->

  class Contrib extends itemVM

    constructor: (resource, _index) ->
      @ref = ko.observable()
      @name = ko.observable().extend
        required:
          message: "Имя должно быть заполнено."
        minLength:
          message: "Имя должно сотоять как минимум из 3-х символов."
          params: 3
      ###
      @url = ko.observable().extend
        required:
          message: "Ссылка должна быть заполнена."
        pattern:
          message: "Ссылка имеет неверный формат."
          params: "^(https?:\\/\\/)?([\\da-z\\.-]+)\.([a-z\\.]{2,6})([\\/\\w \\.-]*)*\\/?$"
      ###
      @isSelected = ko.observable()
      super "contrib", _index

    onCreateItem: ->
      new Contrib @resource, @_index

    onCreate: (done) ->
      data = @toData()
      if @_index._graph then data.graph_ref = @_index._graph.ref()
      dataProvider.ajax "contribs", "post", data, done

    onRemove: (done) ->
      data = @toData()
      dataProvider.ajax "contribs", "delete", data, done

    onUpdate: (done) ->
      data = @toData()
      dataProvider.ajax "contribs", "put", data, done

    create: (done) ->
      super (err) =>
        done err
        if !err
          @openContrib()

    openContrib: ->
      pubSub.pub "href", "change", href: "/contrib/item/#{@ref()}"

    copy: ->
      dataProvider.ajax "contribs", "copy", {ref : @ref()}, (err, data) ->
        pubSub.pub "msg", "show", {err: (if err then err.message else null), msg: "copy success"}
