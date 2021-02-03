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
  # :editと:updateを追加しました。今回使っていくのはこの2つのアクションです。続けてコントローラを編集します。コードが長くなってきたので、修正箇所のみ記載します。
  # :destroyを追加しました。destroyはその名の通りレコードを削除するためのアクションです。これで、Railsに標準で定義されている7つのアクションが出揃いました。ここで、11行目を以下のように修正しましょう。
  resources :articles do
    collection do
      post "markdown"
      # post "set_blob"
      # 15行目を追加しました。今回はsearchという自作アクションを使います。続いて、コントローラを編集します。
      post "search"
      get "set_draft"
    end

    # 18~20行目を追加しました。12~17行目のcollection do~endとは異なり、member do~endという記述を使います。member do~endは、collection do~endと異なり、params[:id]を受け取れます。

    #   params[:id]について説明するため、自作アクションの話から一旦離れて、resourcesで定義できる7つのアクションの話をします。resourcesではindex, new, create, edit, update, show, destroyの7つのメソッドが定義できますが、index, new, createはparams[:id]を受け取らず、edit, update, show, destroyはparams[:idを受け取ります。この違いは「対象となる記事があるかどうか」です。編集(edit, update)や閲覧(show)、削除(destroy)といったアクションは、どの記事に対してアクションを起こすかが決まってなければいけません。

    #   自作メソッドの話に戻ります。今回新しく定義するlikeアクションは「どの記事をいいねするか」が決まってなければいけません。このため、searchなど対象の記事が決まっていなくてもOKで、collection do~endで定義できるアクションと一括りにすることができません。このため、member do~endという記述を使い、params[:id]を受け取る必要があるのです。
    member do
      get "like"
    end
  end
  # 17行目を追加しました。tagモデルについてのshowアクションを使ってタグ検索機能を作ります。という事で、対応するコントローラが必要になったので作成します。
  resources :drafts, except: [:new, :create]
  resources :tags, only: :show
end