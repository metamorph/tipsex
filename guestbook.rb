require 'sinatra'

## ROUTES ##

get '/' do
    redirect to("/posts")
end

get '/posts' do
    @start_at = request["start_at"] || "0"
    "Listing all the posts, starting from #{@start_at}"
end

put '/post' do
    "This is where you will be creating a post"
end


