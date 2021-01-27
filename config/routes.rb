# 11~15行目を編集し、markdownという自作メソッドを定義しました。続けて、コントローラでこのメソッドの中身を作ります。中身は、先ほど説明した通り「JavaScriptからユーザが入力した内容を受け取り、変数=markdown(中身)とした後に、JavaScriptに変数を返す」という内容であればいいわけです。
Rails.application.routes.draw do
  devise_for :users, controllers: {
    registrations: 'users/registrations'
  }
  devise_scope :user do
    get  'profiles', to: 'users/registrations#new_profile'
    post 'profiles', to: 'users/registrations#create_profile'
  end
  $date = Time.now.in_time_zone('Tokyo').to_s
  root "articles#index"
  resources :articles, only: [:index, :new, :create, :show] do
    collection do
      post "markdown"
    end
  end
end