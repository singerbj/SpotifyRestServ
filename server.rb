#!/usr/bin/env ruby

require 'sinatra'

puts "Starting server..."

require 'hallon'
require 'hallon-openal'
require 'json'

configure do
  set :logged_in, false
  set :session, Hallon::Session.initialize(IO.read('./spotify_appkey.key'))
  set :player, Hallon::Player.new(Hallon::OpenAL)
  set :status, {:playing => false, :text => ""}

  Thread.new do
    while true do
      sleep 1
      settings.session.process_events
    end
  end

  settings.session.on(:end_of_track) do
    settings.status[:playing] = false
    settings.status[:text] = ""
  end
end

post '/login' do
  begin
    if settings.logged_in == true
      r = "Already logged in!"
      puts r
    else
      puts "Connecting and logging in..."
      request.body.rewind
      request_body = JSON.parse(request.body.read)
      settings.session.login!(request_body["username"], request_body["password"])
      settings.logged_in = true
      r = "Successfully logged in!"
      puts r
    end
  rescue
      r = "Login error!"
      puts r
  end
  r 
end

post '/logout' do
  begin
    if settings.logged_in == true
      puts "Logging out..."
      settings.player.stop
      settings.session.logout
      settings.logged_in = false
      settings.status[:text] = ""
      settings.status[:playing] = false
      r = "Successfully logged out!"
      puts r
    else
      puts "No one logged in!"
      r = "No one logged in!"
      puts r
    end
  rescue
      puts "Logout error!"
      r = "Logout error!"
      puts r
  end
  r 
end
 

get '/' do
  "This is the root"
end

get '/status' do
  r = JSON.generate(settings.status)
  puts r
  r
end

post '/play' do
  begin
    if settings.logged_in == true
      if request.body.length > 0
        request.body.rewind
        request_body = JSON.parse(request.body.read)
        track = Hallon::Track.new(request_body["song"]).load
        if track
          r = "#{track.name} by #{track.artist.name}"
          settings.status[:text] = r
          settings.status[:playing] = true
          puts r
        else
          r = "No song found..."
          settings.status[:text] = ""
          settings.status[:playing] = false
          puts r
        end
        settings.player.stop
        settings.player.play(track)
      else
        settings.player.play
        settings.status[:playing] = true
        r = settings.status[:text]
        puts r
      end
    else
      r = "No one logged in!"
      puts r
    end
  rescue
    r = "Error playing song..."
    puts r
  end
  r 
end 

post '/pause' do
  begin
    if settings.logged_in == true
      settings.player.pause
      r = "Pausing #{settings.status[:text]}"
      settings.status[:playing] = false
      puts r
    else
      r = "No one logged in!"
      puts r
    end
  rescue
    r = "Error pausing song..."
    puts r
  end
  r 
end  

puts "Server started..."
