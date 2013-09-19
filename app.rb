#!/usr/bin/env ruby
require 'sinatra'

class Post
    # Static field holding all posts
    @posts = []

    def self.create(sender, subject, body)
        @posts << Post.new(@posts.size, sender, subject, body)
    end
    def self.all
        @posts
    end
    def self.find(id)
        @posts.find do |elm|
            id == elm.id
        end
    end
    def self.init
        puts "INITIALIZING POSTS"
        create("Klas", "Hello", "First post here!")
        create("Anders", "Zip zap", "Foo falkjalk sdhgf akdjf aldjk h ")
        create("Martin", "Lorem fck", "Lorem ipsum dolor sit amet, consectetur
        adipisicing elit, sed do eiusmod tempor incididunt ut labore et dolore
        magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation
        ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute
        irure dolor in reprehenderit in voluptate velit esse cillum dolore eu
        fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident,
        sunt in culpa qui officia deserunt mollit anim id est laborum.")
    end

    attr_reader :id, :sender, :subject, :body, :created_at
    def initialize(id, sender, subject, body)
        @id, @sender, @subject, @body, @created_at =
            id, sender, subject, body, Time.now
    end
end

configure do
    Post.init 
end

get '/' do
    redirect to("/posts")
end
get '/posts' do 
    erb :posts, :locals => {:title => "Inlägg", :posts => Post.all.reverse, :page => :posts}
end
get '/new_post' do
    erb :new_post, :locals => {:title => "Nytt inlägg", :page => :write}
end
post '/new_post' do
    Post.create(request["from"], request["subject"], request["body"])
    redirect to("/posts")
end

