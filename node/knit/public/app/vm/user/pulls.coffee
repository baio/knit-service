define ["ural/vm/indexVM", "app/vm/user/pull"]
, (indexVM, Pull) ->


  class Pulls extends indexVM

    constructor: (@_graph)->
      super "pull"

    onCreateItem: ->
      new Pull @resource, @, @_graph
