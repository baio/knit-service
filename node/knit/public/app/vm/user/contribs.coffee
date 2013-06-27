define ["ural/vm/indexVM", "app/vm/user/contrib"]
, (indexVM, Contrib) ->


  class Contribs extends indexVM

    constructor: (@_graph) ->
      super "contrib"

    onCreateItem: ->
      new Contrib @resource, @
