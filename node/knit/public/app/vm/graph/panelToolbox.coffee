define ["ural/modules/pubSub"], (pubSub) ->

  class PanelToolbox

    constructor: (@nav, @panel)->
      @isShown = ko.observable(false)
      @colorScheme = ko.observable(0)
      @colorSchemesList = ko.observableArray([
        {key: 0, val: "Темная"}
        {key: 1, val: "Светлая"},
      ])
      @colorScheme.subscribe((val) =>
        if val == 0
          $("#_body").removeClass("light")
          $("#show_toolbox_panel_button").css(color: "white")
          @panel.updateText(@_getTextCls())
        if val == 1
          $("#show_toolbox_panel_button").css(color: "black")
          $("#_body").addClass("light")
          @panel.updateText(@_getTextCls())
      )
      @font = ko.observable(0)
      @fontsList = ko.observableArray([
        {key: 0, val: "Маленькие"},
        {key: 1, val: "Большие"},
        {key: 2, val: "Не показывать"}
      ])
      @font.subscribe =>
        @panel.updateText(@_getTextCls())
      @layout = ko.observable(0)
      @layoutsList = ko.observableArray([
        {key: 0, val: "Использовать силу связей"},
        {key: 1, val: "Не использовать"}
      ])
      @layout.subscribe (val) =>
        @panel.setForceLayout(val == 0)

      ####
      @activeTab = ko.observable("find")
      @activeTab.subscribe((val) =>
        $("a[href=#_panel_toolbox_#{val}]").tab("show")
      )
      @from = ko.observable()
      @to = ko.observable()
      @isManyPaths = ko.observable(false)

      @foundNodes = []
      @findNode = ko.observable()
      @findNode.subscribe((val) =>
        @panel.higlightSearch val
      )

    _getTextCls: ->
      cls = "text"
      if @colorScheme() == 1
        cls += " light"
      if @font() == 1
        cls += " big"
      else if @font() == 2
        cls += " hidden"
      cls

    reset: ->
      @panel.resetPositions()

    hide: ->
      @isShown false

    show: ->
      @isShown true

    getSettingsName : -> "panelToolbox"

    initializeSettings: (val, @_settingsChangedCallback) ->

      if val
        if val.colorScheme
          @colorScheme(val.colorScheme)
        if val.font
          @font(val.font)
        if val.layout
          @layout(val.layout)
        if val.isShown?
          @isShown(val.isShown)
        if val.from
          @from(val.from)
        if val.to
          @to(val.to)
        if val.isManyPaths
          @isManyPaths(val.isManyPaths)
        if val.activeTab
          @activeTab(val.activeTab)

      @isShown.subscribe =>
        @onSettingsChanged()
      @colorScheme.subscribe =>
        @onSettingsChanged()
      @font.subscribe =>
        @onSettingsChanged()
      @layout.subscribe =>
        @onSettingsChanged()
      @activeTab.subscribe =>
        @onSettingsChanged()
      @from.subscribe =>
        @onSettingsChanged()
      @to.subscribe =>
        @onSettingsChanged()
      @isManyPaths =>
        @onSettingsChanged()

    _getSettings: ->
      colorScheme : @colorScheme()
      font : @font()
      layout : @layout()
      isShown : @isShown()
      from : @from()
      to : @to()
      isManyPaths: @isManyPaths()
      activeTab : @activeTab()

    onSettingsChanged: ->
      if @_settingsChangedCallback
        @_settingsChangedCallback @_getSettings()

    find: (data, event)->
      event.preventDefault()
      pubSub.pub "crud", "reload", _body: {from: @from(), to: @to(), isManyPaths: @isManyPaths()}


    switchActive: (data, event) ->
      event.preventDefault()
      #$(event.currentTarget).tab('show')
      r = $(event.currentTarget).attr("href").match /#_panel_toolbox_(\w+)/
      @activeTab r[1]