// Generated by CoffeeScript 1.6.2
(function() {
  require.config({
    baseUrl: "/"
  });

  require(["ural/localization/localizationManager", "ural/router", "ural/vm/itemVM", "ural/bindings/_all", "app/bindings/autocompleteWithScheme", "app/bindings/tag-editWithScheme", "app/config", "ural/libs/localization/ru/moment.ru"], function(localManager, router, itemVM, bindingOpts, autocompleteWithScheme, tagedit, config) {
    var autocmpleteConfig, rr;

    localManager.setup("en");
    ko.validation.configure({
      messagesOnModified: true,
      insertMessages: false
    });
    itemVM.KeyFieldName = "_id";
    autocmpleteConfig = {
      baseUrl: config.base_url,
      fields: {
        key: "key",
        value: "val",
        label: "val"
      },
      data: {
        term: "term"
      },
      toData: function(d) {
        return {
          type: ko.observable(d.data.type),
          val: ko.observable(d.data.val)
        };
      },
      labelField: "val"
    };
    $.extend(bindingOpts.autocomplete, autocmpleteConfig);
    $.extend(bindingOpts.tagedit, autocmpleteConfig);
    $.jStorage.set("app_reload", "true");
    rr = new router.Router("app/controllers");
    rr.onSwitchLoadingView = function() {
      $("#layout_loading").show();
      $("#layout_content").hide();
      $(".loading_quote").hide();
      return $("#loading_quote_" + (Math.floor(Math.random() * (5 - 1 + 1)) + 1)).show();
    };
    return rr.startRouting([
      {
        url: "/",
        path: {
          controller: "graph",
          action: "panel"
        }
      }, {
        url: "{controller}/{action}/:id:"
      }
    ]);
    /*
    router.Router.StartRouting "app/controllers",
      [
        { url: "/", path : {controller : "graph", action : "panel"} }
        { url: "{controller}/{action}/:id:" }
      ]
    */

  });

}).call(this);

/*
//@ sourceMappingURL=main.map
*/
