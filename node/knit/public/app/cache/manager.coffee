define ["app/config", "app/cache/graph", "app/cache/curUser", "app/cache/contrib"],
(
  config
  graph,
  curUser,
  contrib
) ->

  (resource) ->
    if config.disable_cache then return null
    switch resource
      when "graphs" then graph
      when "curUser" then curUser
      when "contribs" then contrib
      else null