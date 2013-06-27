define [
        "ural/vm/itemVM"
        "app/dataProvider"
        "ural/modules/pubSub",
]
, (itemVM, dataProvider, pubSub) ->

  class Push extends itemVM

    constructor: (resource, _index, @_graph) ->
      @dest_user = ko.observable()
      @dest_graph = ko.observable()
      @status = ko.observable()
      super "push", _index
      @displayText = ko.computed =>
        @dest_user() + "-" + @status()

    onCreateItem: ->
      new Graph @resource, @_graph

    onCreate: (done) ->
      data = @toData()
      dataProvider.ajax "pushes", "post", data, done

    onRemove: (done) ->
      data = @toData()
      dataProvider.ajax "pushes", "delete", data, done

    onUpdate: (done) ->
      data = id: @ref(), name: @name(), contribs: @_contribs.list().filter((f) -> f.isSelected()).map((m) -> m.ref())
      dataProvider.ajax "pushes", "put", data, done
