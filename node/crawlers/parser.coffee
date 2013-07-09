exports.parsePeople = (batch) ->

  batch.results.bindings.map (d) -> d.s.value