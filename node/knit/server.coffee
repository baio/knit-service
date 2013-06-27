connect = require("connect")
passport = require('passport')
TwitterStrategy = require('passport-twitter').Strategy
MongoStore = require("./mongo/connect-mongodb")
url = require("url")
#Cookies = require("cookies")
dispatchers =
  users : require("./dispatchers/users")
  graphs : require("./dispatchers/graphs")
  contribs : require("./dispatchers/contribs")
  names : require("./dispatchers/names")
  tags : require("./dispatchers/tags")
  pushes : require("./dispatchers/pushes")
  curUser : require("./dispatchers/curUser")
  index : require("./dispatchers/index")

_redirect = (req, res, next) ->
  res.redirect = (url) ->
    @writeHead(302, {'Location' : url})
    @end()
  next()

_router = (req, res, next) ->
  url_parsed = url.parse(req.url, true)
  path = url_parsed.pathname
  if path == "/auth/logout"
    req.session.destroy()
    req.logout()
    res.writeHead(302, {'Location' : '/'})
    res.end()
  else if path == "/auth/twitter"
    console.log "auth"
    passport.authenticate('twitter')(req, res, next)
  else if path == "/auth/twitter/callback"
    passport.authenticate('twitter', {successRedirect: '/', failureRedirect: '/login'})(req, res, next)
  else if path == "/"
    #cookies = new Cookies(req, res)
    #cookies.set("auth", if req.user then req.user.name else null)
    req.url = "/main.html"
    #console.log url_parsed.query
    #if url_parsed.query and url_parsed.query.hash
    #req.url = "/main.html#" + url_parsed.query.hash
    #console.log req.url
    next()
  else if path.match /^\/srv\/\w+$/
    match = /^\/srv\/(\w+)$/.exec(path)
    srv_path = match[1]
    srv_method = req.method.toLowerCase()
    dispatchers[srv_path][srv_method](req, res)
  else if path.match /^[\/\w+]+$/
    #req.url = "/main.html"
    #next()
    res.writeHead(302, {'Location' : '/?hash=' + path})
    res.end()
  else
    next()

passport.use new TwitterStrategy
  consumerKey: process.env.TWITTER_CONSUMER_KEY,
  consumerSecret: process.env.TWITTER_CONSUMER_SECRET,
  callbackURL: process.env.TWITTER_CALLBACK,
  (token, tokenSecret, profile, done) ->
    done null, { name: "twitter@" + profile.username, displayName: profile.displayName, img: profile.photos[0].value }

passport.serializeUser (user, done) ->
  done null, user.name + "|" + user.displayName + "|" + user.img

passport.deserializeUser (id, done) ->
  sp = id.split "|"
  done null, name: sp[0], displayName: sp[1], img: sp[2]

#connopts = mongoconn.str2config(process.env.MONGO_STORE)
#db = new mongodb.Db(connopts.db, new mongodb.Server(connopts.host, connopts.port,{}), {w: 1})

connect()
  .use(connect.cookieParser())
  .use(connect.bodyParser())
  .use(_redirect)
  .use(connect.query())
  .use(connect.session secret: process.env.SESSION_SECRET, store: new MongoStore(url: process.env.MONGO_STORE))
  .use(passport.initialize())
  .use(passport.session())
  .use(_router)
  .use(connect.static("public"))
  .listen( process.env.PORT || 8001)