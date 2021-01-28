class ArticlesController < ApplicationController
    before_action :set_article, only: [:show, :edit, :update]
  
    def new
      @article = Article.new
    #   @image = @article.images.new
    end
  
    def create
      @article = Article.new(article_params)
      if @article.valid?
        @article.save
        redirect_to root_path
      else
        render :new
      end
    end

    # editは、newとは違ってArticle.newや@article.images.newなどは必要ありません。新規作成ではなく編集アクションなので、レコードを新たに生成する必要はないのです。その代わり、すでに存在するレコードを読み込んでおく必要があります。3~5行目の記述で、すでに存在する記事本文の画像を読み込んでいます。
    def edit
      @@blob = []
      @article.images.each.with_index do |a,i|
        @@blob << "https://s3-ap-northeast-1.amazonaws.com/soeno-blog-app/#{a.image.path}/#{@article.images[i].image.filename}"
      end
    end

    # createアクションでは@article.saveという記述でレコードを保存しましたが、updateアクションではすでに存在するレコードを更新するための@article.updateという記述を使います。残りはcreateと全て同じです。
    def update
      if @article.valid?
        @article.update(article_params)
        if @@blob != []
          @article.images.each.with_index do |a,i|
            @article.body.gsub!(@@blob[i],"https://s3-ap-northeast-1.amazonaws.com/soeno-blog-app/uploads/image/image/#{a.id}/#{@article.images[i].image.filename}")
            @article.save
          end
        end
        redirect_to root_path
      else
        render :new
      end
    end

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