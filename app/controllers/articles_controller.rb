class ArticlesController < ApplicationController
  
  # showアクションで誰かが記事を閲覧した際、impressionsテーブルにカラムが生成され、PV数がカウントされるようになります。uniqueという記述は、同じ人が何度も記事を閲覧した際に閲覧数が増えてしまうのを防ぐための記述です。インターネットに接続されているパソコンなどの端末に1つ1つ割り当てられている「IPアドレス」というものを利用し、それが同一である場合はカラムを追加しない、という内部処理が行われています。

  # 閲覧数が1増えました！何度か繰り返し閲覧しても1のままなので、IPアドレスによる集計制限が無事に動作していることが分かります。それでは、集計制限を解除するとどうなるか、今一度実験してみましょう。articlesコントローラに先ほど追加した記述を、以下のように書き換えます。

  impressionist actions: [:show], unique: [:impressionable_id, :ip_address]
  # impressionist actions: [:show]
  before_action :set_article, only: [:show, :edit, :update, :destroy, :like]

    # 4~5行目はdraftsテーブルに関する新規レコード生成の記述です。そして6行目はcreateの処理を下書き保存の場合と新規投稿の場合で分けるための記述です。では、続けてarticles#newのビューに下書き保存ボタンを追加しましょう。
    def new
      @article = Article.new
    #   @image = @article.images.new
      @draft = Draft.new
      @draft.images.new
      $draft = false
      $blob = []
    end

    def create
      if $draft
        targetModel = {main: Draft,   tag: Dtag, inter: TagDraft,   column: {main: "draft_id",   tag: "dtag_id"}, redirect: drafts_path}
      else
        targetModel = {main: Article, tag: Tag,  inter: TagArticle, column: {main: "article_id", tag: "tag_id"},  redirect: root_path}
      end
      @article = targetModel[:main].new(article_params)
      if @article.valid?
        @article.save
        # redirect_to root_path
      # else
        # if $blob != []
        #   @article.images.each.with_index do |a,i|
        #     @article.body.gsub!($blob[i],"https://s3-ap-northeast-1.amazonaws.com/soeno-blog-app/uploads/image/image/#{a.id}/#{@article.images[i].image.filename}")
        #     @article.save
        #   end
        # end
        params[:article][:tag].split(" ").each do |p|
          unless targetModel[:tag].find_by(name: p).present?
            targetModel[:tag].create(name: p)
          end
          targetModel[:inter].create(targetModel[:column][:tag] => targetModel[:tag].find_by(name: p).id, targetModel[:column][:main] => @article.id)
        end
        redirect_to targetModel[:redirect]
      else
        render :new
      end
    end

    # editは、newとは違ってArticle.newや@article.images.newなどは必要ありません。新規作成ではなく編集アクションなので、レコードを新たに生成する必要はないのです。その代わり、すでに存在するレコードを読み込んでおく必要があります。3~5行目の記述で、すでに存在する記事本文の画像を読み込んでいます。
    def edit
      $blob = []
      # @article.images.each.with_index do |a,i|
      #   $blob << "https://s3-ap-northeast-1.amazonaws.com/soeno-blog-app/#{a.image.path}/#{@article.images[i].image.filename}"
      # end
      if @article.images.exists?
        @article.images.each.with_index do |a,i|
          @@blog << "https://s3-ap-northeast-1.amazonaws.com/soeno-blog-app/#{a.image.path}/#{@article.images[i].image.filename}"
        end
      end
      tags = []
      TagArticle.where(article_id: @article.id).each do |t|
        tags << Tag.find(t.tag_id).name
      end
      @tag = tags.join(" ")
    end

    # createアクションでは@article.saveという記述でレコードを保存しましたが、updateアクションではすでに存在するレコードを更新するための@article.updateという記述を使います。残りはcreateと全て同じです。
    def update
      TagArticle.where(article: @article.id).destroy_all
      if @article.valid?
        @article.update(article_params)
        if $blob != []
          @article.images.each.with_index do |a,i|
            @article.body.gsub!($blob[i],"https://s3-ap-northeast-1.amazonaws.com/soeno-blog-app/uploads/image/image/#{a.id}/#{@article.images[i].image.filename}")
            @article.save
          end
        end
        # 2行目と11~16行目を追加しました。createとほぼ同じなのですが、2行目だけが異なります。この記述はtag_articlesテーブルに存在する、article_idがこの記事のidと一致するものを全て削除せよという意味です。なぜこんな事をするかというと、ユーザが削除したタグをちゃんと除外してあげるためです。一旦タグを全て削除して、ユーザが入力欄に残しているタグを再登録する、という動作をする事で「タグの削除」を実現しています。
        params[:article][:tag].split(" ").each do |p|
          unless Tag.find_by(name: p).present?
            Tag.create(name: p)
          end
          TagArticle.create(tag_id: Tag.find_by(name: p).id, article_id: @article.id)
        end
        redirect_to root_path
      else
        render :new
      end
    end

    # まず、before_action :set_articleに:destroyを追加します。どの記事を削除するか分からないと削除できないですからね。あとはdef destroyを作ります。4行目で、削除しようとしている人のid(current_user.id)がその記事の筆者のid(@article.user_id)と一致している事を確認します。そして5行目の@article.destoryという記述で、記事を削除できます。また、削除が成功するとルートパスにリダイレクトします。
    def destroy
      if @article.user_id == current_user.id
        if @article.destroy
          redirect_to root_path
        end
      end
    end

    # 2行目は検索ボックスが空のままsearchアクションが起動されたら、何もしないという意味の記述です。3行目が本体で、.where(...)を使ってarticlesテーブルからレコードを検索するのですが、その条件の指定方法が少し特殊になっています。まず"title LIKE ?"という記述は「titleカラムからあいまい検索をする」という意味になります。あいまい検索とは、単語が部分的に一致していれば「一致した」という判定を与えることです。"%params[:search]%"という部分は、params[:search]で検索をするという意味です。params[:search]は検索ワードであり、このあとform_withでビュー側からこのコントローラに与えます。また、%が両端についているのも「あいまい検索」をするための記述です。
    def search
      return nil if params[:search] == ""
      @articles = Article.where(["title LIKE ? OR body LIKE ?", "%#{params[:search]}%", "%#{params[:search]}%"])
    end

    # 2行目の条件分岐は「いいね済みかどうか」を判断しています。likesテーブルにそのユーザのレコードが存在すればいいね済みなので、存在しない場合という意味で条件を「レコード == nil」と書いています。未いいねの場合は3行目でlikesテーブルのレコードを作成し、いいね済みであれば逆にレコードを削除します。
    def like
      if Like.find_by(article_id: @article.id, user_id: current_user.id) == nil
        Like.create(article_id: @article.id, user_id: current_user.id)
      else
        Like.find_by(article_id: @article.id, user_id: current_user.id).destroy
      end
    end

    # 3行目のContactMailer.send_contactという記述で先ほど定義したcontact_mailer.rbのsend_contactメソッドを呼び出せます。続けて、各paramsをsend_mailメソッドに与えるために、form_withをnew_mailのビューに定義しましょう。
    # def send_mail
    #   if(params[:name] != "" && params[:email] != "" && params[:body] != "")
    #     ContactMailer.send_contact(params[:name], params[:email], params[:body]).deliver
    #   else
    #     render :new_mail
    #   end
    # end

    # def show_card
    #   card = Card.find_by(user_id: current_user.id)
    #   if card.blank?
    #     redirect_to :new
    #   else
    #   Payjp.api_key = Rails.application.credentials.payjp[:secret_key]
    #   customer = Payjp::Customer.retrieve(card.customer_id)
    #   @default_card_information = Payjp::Customer.retrieve(card.customer_id).cards.data[0]
    #   end
    # end

    # この部分でやっているのは「JavaScriptからユーザが入力した内容を受け取る」という部分です。
    def markdown
        @body = params[:body]
    end

    private
    def article_params
      params[:article].permit(:title, :thumbnail, :abstract, :body).merge(user_id: current_user.id)
    # 6行目を追加し、25行目にimages_attributes: [:image, :_destroy, :id]という記述を追加しました。これらもfields_forを使うために必要な記述になります。
    #   params[:article].permit(:title, :thumbnail, :abstract, :body, images_attributes: [image, :_destroy, :id]).merge(user_id: current_user.id)
    end

    def set_article
      @article = Article.find(params[:id])
    end

  end