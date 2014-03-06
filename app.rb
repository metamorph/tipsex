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

# Enable to show debug SQL logging
# DataMapper::Logger.new(STDOUT, :debug)
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
    def hdate(date)
        today = Date.today
        yesterday = today - 1
        prefix = if today.year == date.year && 
            today.month == date.month &&
            today.day == date.day
            "Idag"
        elsif yesterday.year == date.year && 
            yesterday.month == date.month &&
            yesterday.day == date.day
            "Igår"
        else
            date.strftime("%d/%m")
        end
        "#{prefix} #{date.strftime("%H:%M")}"
    end
end

get '/' do
    redirect to("/posts")
end
get '/posts/?:page?' do |page| 
    @page_current = page.nil? ? 1 : page.to_i
    @offset = (@page_current - 1) * 5
    @posts = Post.all(:order => :id.desc, :limit => 5, :offset => @offset)
    @page_count = (Post.all.count / 5.0).ceil
    erb :posts, :locals => {
        :posts => @posts,         
        :page_count => @page_count,
        :page_current => @page_current,
        :page => :posts}
end
get '/new_post' do
    @post = Post.new
    erb :new_post, :locals => {:page => :write}
end
post '/new_post' do
    @post = Post.new
    @post.attributes = params[:post].merge(:created_at => Time.now)
    if params[:captcha]["token"] != 'tipsex' 
        flash.now[:form_error] = "Du glömde det magiska lösenordet!"
        erb :new_post, :locals => {:page => :write}
    else
        if @post.save
            flash[:notice] = "Inlägget är publicerat!"
            redirect to("/posts")
        else
            flash.now[:form_error] = @post.errors.map do |e|
                e.first[:presence]
            end.join("<br/>")
            erb :new_post, :locals => {:page => :write}
        end
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

    if params[:captcha]["token"] != 'tipsex'
        flash.now[:form_error] = "Du glömde det magiska lösenordet!"
        erb :post, :locals => {:page => :post, :post => @post, :comment => @comment}
    else
        if @comment.save
            flash[:notice] = "Kommentaren tillagd"
            redirect to("/post/#{pid}")
        else
            flash.now[:form_error] = @comment.errors.map do |e|
                e.first[:presence]
            end.join("<br/>")
            erb :post, :locals => {:page => :post, :post => @post, :comment => @comment}
        end
    end
end
# List the recent activities (30 days)
get '/recent' do
    # Select them.
    date_limit = Time.now - (30 * 24 * 60 * 60)
    posts = Post.all(:created_at.gt => date_limit)
    comments = Comment.all(:created_at.gt => date_limit)
    # merge them, ordered by date.
    @entries = (posts.to_a + comments.to_a).sort{|a,b| b.created_at <=> a.created_at}
    erb :recent, :locals => {:page => :recent}
end
get '/faq' do
    erb :faq, :locals => {:title => "FAQ", :page => :faq}
end

