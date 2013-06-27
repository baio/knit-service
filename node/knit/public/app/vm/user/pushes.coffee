define ["ural/vm/indexVM", "app/vm/user/push"]
, (indexVM, Push) ->


  class Pushes extends indexVM

    constructor: (@_graph)->
      super "push"

    onCreateItem: ->
      new Push @resource, @, @_graph
