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

  @db.execute 'create table if not exists "Comments"
  (
    "id" INTEGER PRIMARY KEY AUTOINCREMENT,
    "created_date_comment" DATE,
    "content_comment" TEXT,
    "post_id" INTEGER
  )'
end

get '/' do
  # выбираем список постов из БД
  @results = @db.execute 'select * from Pasts order by id desc'
  erb :index
  
end

# обработчик get-запроса /new (браузер получает страницу с сервера)
get '/new' do
  erb :new
end

# обработчик post-запроса /new (браузер отправляет данные на сервера)
post '/new' do
  # получаем переменную из post-запроса
  content = params[:content]

  if content.length <= 0
    @error = 'Type post text'
    return erb :new
  end

  # сохранение в БД
  @db.execute 'insert into Pasts (content, created_date) values(?, datetime())', [content]

  # перенаправление на страницу
  redirect to '/'

end

# вывод информации о посте
get '/details/:post_id' do
  # Получаем переменную из url'a
  post_id = params[:post_id]
  
  # получаем список постов(у нас только один пост)
  res = @db.execute 'select * from Pasts where id = ?', [post_id]
  # выбираем это один пост в переменную @row
  @row = res[0]

  # выбираем коментарии к нашему посту
  @comments = @db.execute 'select * from Comments where post_id = ? order by id', [post_id]

  # возвращаем представление details.erb
  erb :details
end

# обработчик post-запроса /new (браузер отправляет данные на сервера)
post '/details/:post_id' do
  # Получаем переменную из url'a
  post_id = params[:post_id]

  # получаем переменную из post-запроса
  content_comment = params[:content_comment]

  # Сохраняем данные коментария под постом в БД
  @db.execute 'insert into Comments (content_comment, created_date_comment, post_id)
  values (?, datetime(), ?)', [content_comment, post_id]
  
  # перенаправление на страницу поста
  redirect to('/details/' + post_id)

end

