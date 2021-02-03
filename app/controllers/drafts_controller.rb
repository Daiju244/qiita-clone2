# 中身はほぼarticlesコントローラのコピペです。しかし、保存先のテーブルはarticlesではなくdraftsになります。TagはDtag、TagArticleはTagDraftと対応しています。

# このメソッドは「下書き保存ボタン」をクリックさえすれば動くはずなのに、なぜ@@blobが定義されてないことになるのでしょうか？結論、@@blobは定義されていないのではなく「定義されたが、消えた」のです。

# どういうことなのか説明します。@@blobは、Rubyというプログラミング言語における「変数」の一種です。変数とは、値(数字や文字列)を入れるための箱でした。この箱は、中身を入れてから取り出すまでの「賞味期限」が決まっています。期限が過ぎたものは、箱から取り出すことができずに消滅します。この期限のことをプログラミングの世界では「スコープ」といいます。スコープとは、変数が使える期限、もしくは「範囲」のことをいいます。

# スコープは変数の種類ごとに異なります。私が今まで「以下のように編集しましょう」などと言って、さりげなく定義してきた変数には、頭に「@」が付くもの、「@@」のように2つ付くもの、何も付かないものなど、色々ありましたよね。これが、変数の種類です。このアプリで使用する変数は、以下の4つの種類があります。

# 変数の種類	記法	スコープの広さ	主なスコープ範囲	Railsにおける主な用途
# ローカル変数	hoge	★☆☆☆
# (狭い)	定義された場所の中のみ	あるメソッド(def~end)内でしか使わない変数などに使う
# インスタンス変数	@hoge	★★☆☆	インスタンスメソッド内	コントローラからビューにテーブルの情報を渡すのに使う
# クラス変数	@@hoge	★★★☆	クラス内、クラスメソッド内、インスタンスメソッド内	非同期通信でメソッドをまたいで渡したい変数に使う
# グローバル
# 変数	$hoge	★★★★
# (広い)	プログラム内どこでも使える	上記のいずれでも扱えない変数に使う
# 話を@@blobに戻します。@@blobは「クラス変数」という種類でした。そして、articlesコントローラで定義されています。これをdraftsコントローラで呼び出そうとするとどうなるか？呼び出せません、消滅しているので。articlesコントローラにとって、draftsコントローラはクラス内でも、クラスメソッド内でも、インスタンスメソッド内でもありません。クラスって何？という感じかもですが、今のところ「メソッド(def~end)のかたまり」くらいに考えてもらえればOKです。

# articlesコントローラにとってdraftsコントローラは「別のクラス」なので、クラス変数を引き継いで使うことができません。なので、ソースコード内の@@blobを全て$blobに置き換えましょう。

class DraftsController < ApplicationController
    before_action :set_draft, only: [:show, :edit, :update, :destroy]
  
    def edit
      $draft = false
      $blob = []
      if @draft.images.exists?
        @draft.images.each.with_index do |a,i|
          $blob << "https://s3-ap-northeast-1.amazonaws.com/soeno-blog-app/#{a.image.path}/#{@draft.images[i].image.filename}"
        end
      end
      tags = []
      TagDraft.where(draft_id: @draft.id).each do |t|
        tags << Dtag.find(t.dtag_id).name
      end
      @tag = tags.join(" ")
    end

    # 全体的に修正をしましたが、基本的な考え方はarticles#createで行った条件分岐とほぼ同じです。大きく異なる点は、50~52行目です。下書き投稿後はarticlesテーブルに記事が投稿されるので、draftsテーブルに残った下書きは必要なくなります。なので、51行目で対象の下書きを削除します。

    # また、draftsコントローラにはupdateアクション以外にも編集すべきメソッドが1つあります。draft_paramsというメソッドです。この部分も、下書き投稿か、記事投稿かで処理を分ける必要があるのです。以下のように修正しましょう。
    def update
        TagDraft.where(draft: @draft.id).destroy_all
        if $draft
          targetModel = {tag: Dtag, inter: TagDraft,   column: {main: "draft_id",   tag: "dtag_id"}, redirect: drafts_path}
          if @draft.valid?
            @draft.update(draft_params)
          else
            render :edit
          end
        else
          targetModel = {tag: Tag,  inter: TagArticle, column: {main: "article_id", tag: "tag_id"},  redirect: root_path}
          @draft = Article.new(draft_params)
          if @draft.valid?
            @draft.save
          else
            render :edit
          end
        end
        if $blob != []
          @draft.images.each.with_index do |a,i|
            @draft.body.gsub!($blob[i],"https://s3-ap-northeast-1.amazonaws.com/soeno-blog-app/uploads/image/image/#{a.id}/#{@draft.images[i].image.filename}")
            @draft.save
          end
        end
        params[:draft][:tag].split(" ").each do |p|
          unless targetModel[:tag].find_by(name: p).present?
            targetModel[:tag].create(name: p)
          end
          targetModel[:inter].create(targetModel[:column][:tag] => targetModel[:tag].find_by(name: p).id, targetModel[:column][:main] => @draft.id)
        end
        unless $draft
          Draft.find(params[:id]).destroy
        end
        redirect_to targetModel[:redirect]
      end
  
    def destroy
      if @draft.user_id == current_user.id
        if @draft.destroy
          redirect_to root_path
        end
      end
    end
  
    # draftsコントローラにはupdateアクション以外にも編集すべきメソッドが1つあります。draft_paramsというメソッドです。この部分も、下書き投稿か、記事投稿かで処理を分ける必要があるのです。以下のように修正しましょう。
    # この修正については深く考えなくてもいいのですが、Carrierwaveというgemの仕様上、今回行ったような「draftsコントローラのeditアクションから、articlesモデルのレコードを生成する」という事をする際に、画像のレコードが引き継げなくなる問題があるので、6行目でthumbnailカラムについて追加の処理を行っています。
    private
    def draft_params
      if $draft
        params[:draft].permit(:title, :thumbnail, :abstract, :body, images_attributes: [:image, :_destroy, :id]).merge(user_id: current_user.id)
      else
        params[:draft].permit(:title, :abstract, :body, images_attributes: [:image, :_destroy, :id]).merge(user_id: current_user.id, thumbnail: @@thumbnail)
      end
    end
  
    def set_draft
      @draft = Draft.find(params[:id])
      $draft = true
    end
  
  end
