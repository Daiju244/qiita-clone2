class ArticlesController < ApplicationController
    before_action :set_article, only: :show
  
    def new
      @article = Article.new
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

    # この部分でやっているのは「JavaScriptからユーザが入力した内容を受け取る」という部分です。
    def markdown
        @body = params[:body]
    end
  
    private
    def article_params
      params[:article].permit(:title, :thumbnail, :abstract, :body).merge(user_id: current_user.id)
    end
  
    def set_article
      @article = Article.find(params[:id])
    end
  
  end