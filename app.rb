require 'rubygems'
require 'sinatra'
require 'sinatra/reloader'
require 'sqlite3'

def init_db
  @db = SQLite3::Database.new 'Leprosorium.db'
  @db.results_as_hash = true
end

# before вызывается каждый раз при перезагрузке любой страницы
before do
  # инициализация БД
  init_db
end

# configure вызывается каждый раз при конфигурации приложения:
# когда изменился код программы и перегрузилась страница
configure do
  # инициализация БД
  init_db
  # создаём таблицу если таблица не существует
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

# обработчик get-запроса /new (браузер получает страницу с сервера)
get '/new' do
  erb :new
end

# обработчик post-запроса /new (браузер отправляет данные на сервера)
post '/new' do
  # получаем переменную из post-запроса
  content = params[:content]
  erb "You typed: #{content}"
end