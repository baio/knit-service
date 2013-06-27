define ["ural/controller",
  "app/vm/menu",
  "app/cache/manager"
],
(controller, menu, cache) ->

  _nav = new menu()

  class ControllerBase extends controller.Controller

    constructor: ->
      @nav = _nav
      super

    view_apply_user_important: (path, model, done) ->
      @nav.load null, (err, data)=>
        model._layouts._nav = data : (if !err then data else {})
        ControllerBase.__super__.view_apply.call(@, path, model, done)

    view_apply: (path, model, done) ->
      model._layouts._nav = @nav
      super path, model, done

  Controller : ControllerBase