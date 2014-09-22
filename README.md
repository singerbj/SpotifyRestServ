SpotifyRestServ
===============

A server that puts a simple restful interface on top of libspotify, built with Sinatra, Hallon, and Hallon OpenAL.

To start the server make sure you have ruby and bundler installed, clone the repo, run 
```
bundle install
```
and then run 
```
ruby server.rb -p 5445
```

Then use a Rest Client like postman to interact with the restful interface. The api has the following methods that require their respective JSON objects:

POST "/login" {"username": "xyz", "password":"zyx"}

POST "/logout" (Nothing)

POST "/play" {"song": "spotify uri"} OR Nothing to continue playing after pause

POST "/pause" (Nothing)

GET "/status" (Nothing)
