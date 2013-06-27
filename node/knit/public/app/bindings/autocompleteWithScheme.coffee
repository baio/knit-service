define ["ural/bindings/autocomplete"], ->


  ko.bindingHandlers.autocompleteWithScheme =

    init: (element, valueAccessor, allBindingsAccessor, viewModel) ->
      _opts = allBindingsAccessor().autocompleteOpts
      _opts ?= {}
      _opts.filterParams =
        index: ->
          opts = allBindingsAccessor().autocompleteOpts
          opts.scheme.index
        type: ->
          opts = allBindingsAccessor().autocompleteOpts
          opts.scheme.type

      ko.bindingHandlers.autocomplete.init element, valueAccessor, allBindingsAccessor, viewModel
      opts = allBindingsAccessor()
      console.log opts.autocompleteOpts.scheme

    update: (element, valueAccessor, allBindingsAccessor) ->
      ko.bindingHandlers.autocomplete.update element, valueAccessor, allBindingsAccessor


