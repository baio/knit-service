define ["ural/vm/indexVM",
  "app/vm/contrib/item",
  "app/dataProvider",
  "app/vm/user/contrib"
]
, (indexVM, itemVM, dataProvider, Contrib) ->

  class IndexVM extends indexVM

    constructor: ->
      @schemes = null
      @contrib = new Contrib()
      #@_isModifyed = ko.observable()
      super "contrib-item"

    onCreateItem: ->
      new itemVM(@resource, @)

    onLoad: (filter, done)->
      dataProvider.get "contribs", filter, (err, data) =>
        if !err
          items = data.items
          @schemes = data.schemes
          delete data.items
          @contrib.map data, true
          done err, items
        else
          done null

    onUpdate: (data, done) ->
      d = {id: @contrib.ref(), items: data}
      dataProvider.ajax "contribs", "patch", d, (err, data) ->
        if !err
          data = data.data
        done err, data
