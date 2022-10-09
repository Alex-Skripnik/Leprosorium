require 'rubygems'
require 'sinatra'
require 'sinatra/reloader'
require 'sqlite3'

def init_db
  @db = SQLite3::Database.new 'Leprosorium.db'
  @db.results_as_hash = true
end

before do
  init_db
end

configure do
  init_db
  @db.execute 'create table if not exists "Pasts"
  (
    "id" INTEGER PRIMARY KEY AUTOINCREMENT,
    "created_date" DATE,
    "content" TEXT
  )'
end

get '/' do
  erb 'Can you handle a <a href="/secure/place">secret</a>?'
end

get '/new' do
  erb :new
end

post '/new' do
  content = params[:content]
  erb "You typed: #{content}"
end