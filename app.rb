#!/usr/bin/env ruby

require 'sinatra'
require 'sinatra/form_helpers'
require 'data_mapper'
require 'time'
require 'sinatra/flash'

configure do
    enable :sessions
    set :session_secret, 'j9f784y9fp8jdf'
end

DataMapper::setup(:default, ENV['DATABASE_URL'] || 'postgres://localhost/guestbook')

class Post
    include DataMapper::Resource

    property :id, Serial
    property :from, String, :required => true, :message => {
        :presence => "Du måste ange en avsändare"}
    property :subject, String, :required => true, :message => {
        :presence => "Du måste ange ett ämne"}
    property :body, Text, :required => true, :message => {
        :presence => "Du måste skriva ett meddelande"}
    property :created_at, DateTime, :required => true

    has n, :comments

end
class Comment
    include DataMapper::Resource

    property :id, Serial
    property :from, String, :required => true, :message => {
        :presence => "Du måste ange en avsändare" }
    property :body, Text, :required => true, :message => {
        :presence => "Du måste skriva ett meddelande" }
    property :created_at, DateTime, :required => true

    belongs_to :post
end

DataMapper.finalize
DataMapper.auto_upgrade!

# Some helpers
helpers do
    def _fmt_comments(count)
        case count
        when 0
            "Inga kommentarer"
        when 1
            "1 kommentar"
        else
            "#{count} kommentarer"
        end
    end
    def _fmt_date(date)
        date.strftime("%H:%M, %Y-%m-%d")
    end
    def h(text)
        Rack::Utils.escape_html(text)
    end
end

get '/' do
    redirect to("/posts")
end
get '/posts' do 
    erb :posts, :locals => {
        :posts => Post.all(:order => :id.desc), 
        :page => :posts}
end
get '/new_post' do
    @post = Post.new
    erb :new_post, :locals => {:page => :write}
end
post '/new_post' do
    @post = Post.new
    @post.attributes = params[:post].merge(:created_at => Time.now)
    if @post.save
        flash[:notice] = "Danke!"
        redirect to("/posts")
    else
        flash[:error] = @post.errors.map do |e|
            e.first[:presence]
        end.join("<br/>")
        erb :new_post, :locals => {:page => :write}
    end
end
get '/post/:pid' do |pid|
   erb :post, :locals => {
       :comment => Comment.new,
       :post => Post.get(pid.to_i), 
       :page => :post} 
end
post '/post/:pid' do |pid|
    @post = Post.get(pid.to_i)
    @comment = Comment.new
    @comment.attributes = params[:comment].merge(:created_at => Time.now) 
    @comment.post = @post
    if @comment.save
        flash[:notice] = "Kommentaren tillagd"
        redirect to("/post/#{pid}")
    else
        flash.now[:error] = @comment.errors.map do |e|
            e.first[:presence]
        end.join("<br/>")
        erb :post, :locals => {:page => :post, :post => @post, :comment => @comment}
    end
end
get '/faq' do
    erb :faq, :locals => {:title => "FAQ", :page => :faq}
end

