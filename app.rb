#!/usr/bin/env ruby
require 'sinatra'

class Comment
    attr_reader :sender, :body, :created_at
    def initialize(sender, body)
        @created_at = Time.now
        @sender, @body = sender, body
    end
end
class Post
    # Static field holding all posts
    @posts = []

    def self.create(sender, subject, body)
        post = Post.new(@posts.size, sender, subject, body)
        @posts << post
        post
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
        create("Anders", "..", "Foo falkjalk sdhgf akdjf aldjk h ")
            .add_comment("Stefan", "sdkfjhaslkdjfhalsdjfh")
            .add_comment("Anders", "sdkjfhskjdfhh")
        create("Martin", "Lorem fck", "Lorem ipsum dolor sit amet, consectetur
        adipisicing elit, sed do eiusmod tempor incididunt ut labore et dolore
        magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation
        ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute
        irure dolor in reprehenderit in voluptate velit esse cillum dolore eu
        fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident,
        sunt in culpa qui officia deserunt mollit anim id est laborum.")
    end

    attr_reader :id, :sender, :subject, :body, :created_at, :comments
    def initialize(id, sender, subject, body)
        @id, @sender, @subject, @body, @created_at =
            id, sender, subject, body, Time.now
        @comments = []
    end

    def add_comment(sender, body)
         @comments << Comment.new(sender, body)
         self
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
    # validate input
    Post.create(request["from"], request["subject"], request["body"])
    redirect to("/posts")
end
get '/post/:pid' do |pid|
   erb :post, :locals => {:title => "Inlägg", :post => Post.find(pid.to_i), :page => :post} 
end
post '/post/:pid/comment' do |pid|
    post = Post.find(pid.to_i)
    raise Sinatra::NotFound unless post
    post.add_comment(request["from"], request["body"])
    redirect to("/post/#{pid}")
end
get '/faq' do
    erb :faq, :locals => {:title => "FAQ", :page => :faq}
end

