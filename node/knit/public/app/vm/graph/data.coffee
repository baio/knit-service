define ["ural/vm/itemVM",
        "app/vm/user/contribs",
        "app/dataProvider"
]
, (itemVM, Contribs, dataProvider) ->

  class Data extends itemVM

    constructor: ->
      @ref = ko.observable()
      @name = ko.observable()
      @contribs = new Contribs(@)

    onLoad: (filter, done) ->
      dataProvider.get "graphs", filter, done
