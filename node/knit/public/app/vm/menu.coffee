define ["ural/modules/pubSub", "app/vm/curUser"], (pubSub, curUser) ->

  class ActiveGraph

    constructor: ->
      @id = ko.observable()
      @name = ko.observable()
      @isYours = ko.observable()

    save: (data, event) ->
      event.preventDefault()
      pubSub.pub "graph", "save"

  class Menu

    constructor: ->
      @active = ko.observable()
      @activeGraph = new ActiveGraph()
      pubSub.sub "href", "changed", (data) =>
        @active "/" + data.controller + "/" + data.action

      @user = new curUser()


    load: (filter, done) ->
      @user.load filter, (err) =>
        done err, @

