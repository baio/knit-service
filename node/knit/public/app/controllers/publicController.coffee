define ["app/controllers/controllerBase",
  "app/vm/contrib/index",
  "app/vm/publicContrib/index"
],
(controller, Contrib, PublicContribs) ->

  class PublicController extends controller.Controller

    item: (id)->
      @view_apply "app/views/public/item.html",
        _layouts:
          _body: {loader: new Contrib(), filter: {id: id}}

    index: ->
      @view_apply "app/views/public/index.html",
        _layouts:
          _body: new PublicContribs()

  Controller : PublicController