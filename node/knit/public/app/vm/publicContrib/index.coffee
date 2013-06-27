define ["app/dataProvider"], (dataProvider) ->

  class Index

    load: (filter, done) ->
      dataProvider.get "contribs", filter, done