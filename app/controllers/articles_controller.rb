class ArticlesController < ApplicationController
    before_action :set_article, only: [:show, :edit, :update, :destroy]
  
    def new
      @article = Article.new
    #   @image = @article.images.new
    end
  
    def create
      @article = Article.new(article_params)
      if @article.valid?
        @article.save
        # redirect_to root_path
      # else
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

    # editは、newとは違ってArticle.newや@article.images.newなどは必要ありません。新規作成ではなく編集アクションなので、レコードを新たに生成する必要はないのです。その代わり、すでに存在するレコードを読み込んでおく必要があります。3~5行目の記述で、すでに存在する記事本文の画像を読み込んでいます。
    def edit
      @@blob = []
      # @article.images.each.with_index do |a,i|
      #   @@blob << "https://s3-ap-northeast-1.amazonaws.com/soeno-blog-app/#{a.image.path}/#{@article.images[i].image.filename}"
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
        if @@blob != []
          @article.images.each.with_index do |a,i|
            @article.body.gsub!(@@blob[i],"https://s3-ap-northeast-1.amazonaws.com/soeno-blog-app/uploads/image/image/#{a.id}/#{@article.images[i].image.filename}")
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