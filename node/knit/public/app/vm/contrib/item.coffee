define ["ural/vm/itemVM", "app/dataProvider", "ural/modules/pubSub"], (itemVM, dataProvider, pubSub) ->

  class ItemVM extends itemVM

    constructor: (resource, index) ->
      @name_1 = ko.observable().extend
        required:
          message: "Имя 1 должно быть заполнено."
      ###
      pattern:
        message: 'Имя 1 должно состоять из имени и фамилии разделенных пробелом.'
        params: '^\\s*\\w+\\s+\\w+\\s*$'
        params: '^\\s*[А-Я]?[а-я]+\\s+[А-Я]?[а-я]+\\s*$'
      ###
      @name_2 = ko.observable().extend
        required:
          message: "Имя 2 должно быть заполнено."
      ###
      pattern:
        message: 'Имя 2 должно состоять из имени и фамилии разделенных пробелом.'
        params: '^\\s*\\w+\\s+\\w+\\s*$'
        params: '^\\s*[А-Я]?[а-я]+\\s+[А-Я]?[а-я]+\\s*$'
      ###
      @url = ko.observable().extend
        required:
          message: "Ссылка на источник долна быть заполнена."
        pattern:
          message: 'Ссылка на источник имеет неверный формат.'
          params: '^(https?:\\/\\/)?([\\da-z\\.-]+)\\.([a-z\\.]{2,6})([\\/\\w\\,_%\\.-]*)*\\/?$'
          #params: '^(https?:\\/\\/)?([\\da-z\\.-]+)\\.([a-z\\.]{2,6})([\\/\\w \\.-]*)*\\/?$'
      @relations = ko.observableArray([]).extend
        minLength:
          params: 1
          message: "Должна быть указана хоть одна связь."
      @date = ko.observable()
      @dateTo = ko.observable()
      @source = ko.observable()
      @scheme = ko.observable()
      @_id = ko.observable()
      super resource, index
      @_scheme = ko.computed =>
        res = index.schemes.filter((f) => f["_id"] == @scheme())[0]
        res ?= {}
        res
      @_availableSchemes = ko.observableArray(
        [{id: "person-person.ru", label: "Персона - Персона"},
        {id: "person-org.ru", label: "Персона - Организация"},
        {id: "org-org.ru", label: "Организация - Организация"}])
      @scheme.subscribe (val) =>
        if val
          @_readOnly false
        else
          @_readOnly true
        if @src and val
          @swapFieldsWhenSchemeChanged()
      @_readOnly = ko.observable(true)
      @_isCreateNext = ko.observable(true)
      @headerCss = ko.computed =>
        switch @scheme()
          when "person-person.ru" then "blue"
          when "person-org.ru" then "green"
          when "org-org.ru" then "wiolet"

    onCreate: (done) ->
      data =
        id: @_index.contrib.ref()
        items: [@toData()]
      dataProvider.ajax "contribs", "patch", data, (err, data) =>
        if !err
          @_id data.data[0]._id
        #we don't wont map item from response here, since responce doesn't return item content
        done err, null

    onUpdate: (done) ->
      data =
        id: @_index.contrib.ref()
        items: [@toData()]
      dataProvider.ajax "contribs", "patch", data, (err, data) ->
        #we don't wont map item from response here, since responce doesn't return item content
        done err, null

    onRemove: (done) ->
      item = @toData()
      item._isRemoved = true
      data =
        id: @_index.contrib.ref()
        items: [item]
      dataProvider.ajax "contribs", "patch", data, done

    onGetRemoveType: -> "update"

    onCreateItem: ->
      new ItemVM @resource, @_index

    swapFields: ->
      @_id(null)
      #@name_1(null)
      @name_2(null)
      @relations([])
      #@date(null)
      #@dateTo(null)
      #@source(null)
      @scheme(null)
      @setIsModified(false)
      $("[data-default-focus]", $("[data-form-resource='contrib-item']:visible")).focus()

    swapFieldsWhenSchemeChanged: ->
      if @relations().length
        @relations([])
        @relations.isModified(false)

    onSaved: (err, status) ->
      if !err and status == "create" and @_isCreateNext()
        pubSub.pub "msg", "show", {err: err, msg: "Success"}
        @swapFields()
      else
        super err, status

    setHotKeys: (f) ->
      if f
        Mousetrap.bindGlobal "ctrl+s", =>
          @save()
          false
      else
        Mousetrap.unbind "ctrl+s"
