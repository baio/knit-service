define ["ural/bindings/tag-edit"], ->


  ko.bindingHandlers.tageditWithScheme =

    init: (element, valueAccessor, allBindingsAccessor, viewModel) ->
      _opts = allBindingsAccessor().tageditOpts
      _opts ?= {}
      _opts.filterParams =
        index: ->
          opts = allBindingsAccessor().tageditOpts
          opts.scheme.index
        type: ->
          opts = allBindingsAccessor().tageditOpts
          if Array.isArray(opts.scheme.type) then opts.scheme.type.join(",") else opts.scheme.type
      _opts.getDefault = (label) ->
        opts = allBindingsAccessor().tageditOpts
        default_type = opts.scheme.default_type
        if !default_type
          type = opts.scheme.type
          default_type = if Array.isArray(type) then type[0] else type
        key: label
        label: label
        value: label
        data:
          key: label
          label: label
          val: label
          type: default_type

      ko.bindingHandlers.tagedit.init element, valueAccessor, allBindingsAccessor, viewModel

    update: (element, valueAccessor, allBindingsAccessor) ->
      ko.bindingHandlers.tagedit.update element, valueAccessor, allBindingsAccessor
