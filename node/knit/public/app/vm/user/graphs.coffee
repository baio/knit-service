define ["ural/vm/indexVM", "app/vm/user/graph"]
, (indexVM, Graph) ->


  class Graphs extends indexVM

    constructor: (@contribs) ->
      super "graph"

    onCreateItem: ->
      new Graph @resource, @, @contribs

    switchContentShown: (data, event) ->
      event.preventDefault()
      t = event.currentTarget
      $wcontent = $(t).parent().parent().next(".widget-content")
      if $wcontent.is(':visible')
        $(t).children('i').removeClass('icon-chevron-up')
        $(t).children('i').addClass('icon-chevron-down')
      else
        $(t).children('i').removeClass('icon-chevron-down')
        $(t).children('i').addClass('icon-chevron-up')
      $wcontent.toggle(500);