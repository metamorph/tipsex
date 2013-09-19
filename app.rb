#!/usr/bin/env ruby
require 'sinatra'

before do
    @start_timer = Time.now
end
after do
    puts "Time elapsed: #{Time.now - @start_timer}"
end

get '/foo/*' do |title|
    title = "Default" if title.empty?
    erb :index, :locals => {:title => title}
end

class Foo
    def each
        10.times {|i| yield "#{i}"}
    end
end

get '/bar/*' do |path|
    "Hello, you're asking for #{path}?"
    # Return value can be a string
    # An array [status (Fixnum), headers (Hash), body (#each)]
    # An array [status, body]
    # #each (yielding string)
    # Statuscode
end
