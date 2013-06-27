define ["ural/vm/itemVM",
        "app/vm/user/contribs",
        "app/vm/user/graphs",
        "app/dataProvider"
]
, (indexVM, contribs, graphs, dataProvider) ->

  class User extends indexVM

    constructor: ->
      @_id = ko.observable()
      @contribs = new contribs()
      @graphs = new graphs(@contribs)
      @img = ko.observable()
      @name = ko.computed =>
         if @_id() then @_id().split("@")[1] else null

    onLoad: (filter, done) ->
      dataProvider.get "users", filter, done
