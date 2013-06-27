#!/bin/bash
ENV=production
DISPATCH_URL=http://localhost:8090
TWITTER_CONSUMER_KEY=hFW8HIzuBcRGu96woDZA1w
TWITTER_CONSUMER_SECRET=NZjNZ4bSKng3vplLM7X8TWMtCjXZoQQaoHMtwkSIsE
TWITTER_CALLBACK=http://188.244.44.9:8001/auth/twitter/callback
MONGO_STORE=mongodb://localhost/knit
SESSION_SECRET=groooVe$et
forever start ~/dev/knit/knit/server.js
