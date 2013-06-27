define [
  "ural/vm/itemVM"
  "app/dataProvider"
]
, (itemVM, dataProvider) ->

  class Pull extends itemVM

    constructor: (resource, @_graph) ->
      @src_user = ko.observable()
      @src_graph = ko.observable()
      @status = ko.observable()
      super "pull"
      @displayText = ko.computed =>
        @src_user() + "-" + @status()

    onCreateItem: ->
      new Pull @resource, @_graph

    onUpdate: (done) ->
      data = @toData()
      dataProvider.ajax "pulls", "post", data, done

    accept: ->
      console.log "accept"

    reject: ->
      console.log "reject"