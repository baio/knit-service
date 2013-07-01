async = require "async"
_q = require "./pedia-query"
_q_person_name = require "./pedia-person-name"
_q_org_name = require "./pedia-org-name"
_q_predicate_name = require "./pedia-predicate-name"
_q_children_people = require "./pedia-children-people"
_q_children_orgs = require "./pedia-children-orgs"
es = require "../baio-es/es"
mongo = require "../baio-mongo/mongo"
mongodb = require "mongodb"

_ES_URI = process.env.ES_URI
_SPARQL_URI = "http://dbpedia.org/sparql"

mongo.setConfig(uri: process.env.MONGO_URI)

init_people_query = """
                  select distinct ?s
                  where
                  {
                  {?s dcterms:subject category:Russian_businesspeople.}
                  union
                  {?s dcterms:subject category:Russian_politicians.}
                  union
                  {?s a yago:RussianPoliticians.}
                    }
                  """


#//////////////////////////////

getName = (s, isPerson, done) ->
  if isPerson
    _q_person_name _SPARQL_URI, s, done
  else
    _q_org_name _SPARQL_URI, s, done

getNames = (s, isPerson, done) ->
  async.map s, ((i, ck) -> getName(i, isPerson, ck)), done

#//////////////////////////////

getChildrenOrgs = (s, done) ->
  async.map s, ((i, ck) -> _q_children_orgs(_SPARQL_URI, i, ck)), done

getChildrenPeople = (s, done) ->
  async.map s, ((i, ck) -> _q_children_people(_SPARQL_URI, i, ck)), done

#////////////////////////////////

_names = []

createPrdeicateNames = (domain, items) ->

  async.map items, ((i, ck) -> _q_predicate_name(_SPARQL_URI, i, ck)), (err, results) ->
    if !err
      for r in results
        data = r.map (m) ->
            _id : m.name + ":" + m.lang, _type: domain, val: m.name, lang: m.lang, uri: m.id
        es.bulk _ES_URI, "predicates", data, ->

createNames = (domain, isPerson, items) ->
  data = []
  for i in items
    data = data.concat i.map (m) ->
      _id : m.name + ":" + m.lang, _type: domain, val: m.name, lang: m.lang, uri: m.id

  es.bulk _ES_URI, (if isPerson then "person-names" else "org-names"), data, ->

createRels = (domain, predicateType, rels) ->

  for r in rels

    if r

      items = r.map (m) ->
        _id: new mongodb.ObjectID()
        domain: domain
        type: predicateType
        subject: m.subject
        object: m.object
        predicate: m.predicate
        url: m.subject

      if items.length > 0
        name = items[0].subject.match(/^.*\/(.*)$/)[1]
        doc =
          name : "#{domain} - #{predicateType} - #{name}"
          created : new Date()
          descr: "This set was created automatically, from dbpedia"
          url: items[0].subject
          items: items

        createPrdeicateNames domain, items.map((m) -> m.predicate)

        mongo.insert "contribs", doc, (err, item) ->
          #console.log err, item



#////////////////////////////////

_iterSubjects = (s, isPerson, done) ->
  async.parallel [
    (ck) -> getNames s, isPerson, ck
    (ck) -> getChildrenOrgs s, ck
    (ck) -> getChildrenPeople s, ck
  ], (err, results) ->

    names = results[0]
    orgsRels = results[1]
    peopleRels = results[2]

    newPeople = []
    newOrgs = []

    if names
      createNames("wiki", isPerson, names)

    if peopleRels

      if isPerson
        createRels("wiki", "pp", peopleRels)
        createRels("wiki", "po", orgsRels)
      else
        createRels("wiki", "op", peopleRels)
        createRels("wiki", "oo", orgsRels)

      res = []
      for r in peopleRels
        for rel in r
          if res.indexOf(rel.object) == -1
            res.push rel.object
      newPeople = res.filter (f) -> _names.indexOf(f) == -1

      res = []
      for r in orgsRels
        for rel in r
          if res.indexOf(rel.object) == -1
            res.push rel.object
      newOrgs = res.filter (f) -> _names.indexOf(f) == -1

    if newPeople.length == 0 and newOrgs.length == 0
      done()
    else
      _names = _names.concat newPeople
      _names = _names.concat newOrgs
      async.parallel [
        (ck) ->
          _iterSubjects newPeople, true, ck
        (ck) ->
          console.log newOrgs
          _iterSubjects newOrgs, false, ck
      ], done

_iter = (query, isPerson, done) ->

  _q _SPARQL_URI, query, (err, data) ->
    if !err
      s = data.map (d) -> d.s.value
      _iterSubjects s, isPerson, done
    else
      done err


module.exports = (done) ->
  _iter init_people_query, true, done