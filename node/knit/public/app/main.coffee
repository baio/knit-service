require.config
  baseUrl: "/"

require [
  "ural/localization/localizationManager",
  "ural/router",
  "ural/vm/itemVM",
  "ural/bindings/_all",
  "app/bindings/autocompleteWithScheme",
  "app/bindings/tag-editWithScheme",
  "app/config",
  "ural/libs/localization/ru/moment.ru"
],
  (localManager, router, itemVM, bindingOpts, autocompleteWithScheme, tagedit, config) ->
    localManager.setup "en"
    ko.validation.configure(
      messagesOnModified: true
      insertMessages: false
    )
    itemVM.KeyFieldName = "_id"
    autocmpleteConfig =
      baseUrl: config.base_url
      fields:
        key:  "key"
        value: "val"
        label: "val"
      data:
        term: "term"
      toData: (d) ->
        type: ko.observable(d.data.type)
        val: ko.observable(d.data.val)
      labelField: "val"
    $.extend bindingOpts.autocomplete, autocmpleteConfig
    $.extend bindingOpts.tagedit, autocmpleteConfig

    #swap current user after each reload
    $.jStorage.set "app_reload", "true"
    rr = new router.Router "app/controllers"
    rr.onSwitchLoadingView = ->
      $("#layout_loading").show()
      $("#layout_content").hide()
      $(".loading_quote").hide()
      $("#loading_quote_#{Math.floor(Math.random() * (5 - 1 + 1)) + 1}").show()
    rr.startRouting [
        #{ url: "/", path : {"contrib", action : "item", arg : "518b989739ed9714289d0bc1"} }
        { url: "/", path : {controller : "graph", action : "panel"} }
        { url: "{controller}/{action}/:id:" }
      ]

    ###
    router.Router.StartRouting "app/controllers",
      [
        { url: "/", path : {controller : "graph", action : "panel"} }
        { url: "{controller}/{action}/:id:" }
      ]
    ###
