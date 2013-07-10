exports.parsePeople = (batch) ->

  batch.results.bindings.map (d) -> d.s.value

exports.parseLinks = (batch, data) ->

  linked = batch.results.bindings.map (m) -> object : m.o.value, predicate : m.p.value

  links = linked.map (m) ->
    subject : data.subject
    predicate : m.predicate
    object : m.object
    type : data.type

  console.log links
