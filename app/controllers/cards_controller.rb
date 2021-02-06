class CardsController < ApplicationController

    # form_withで使うための@cardを生成しています。また、カード情報がすでに存在した場合はshowにリダイレクトします。続けて、createを作ります。
    def new
        it Card.fing_by(user_id: curent_user.id) == nil
        @card = Card.new
    else
        redirect_to show_card_cards_path
    end

    # 結構見慣れない記述が多いですが、createアクション全体でやっていることはわりと単純です。newのform_withで送信したparamsを使って、payjpにトークン生成のリクエストを送信しています。
    # 2行目はpayjpにリクエストを送信するのに必要なパスワードです。このパスワードはcredentials.ymlを使用して設定するので、まずはパスワードをpayjpから取得しましょう。パスワードはpayjp公式ページのAPIタグに書いてあります。「テスト用秘密鍵」というのがパスワードです。これをコピーして、以下のコマンドからcredentials.ymlを編集しましょう。
    def create
        Payjp.api_key = Rails.application.credentials.payjp[:secret_key]
        token = Payjp::Token.create({
          card: {
            number:     params[:card][:number],
            cvc:        params[:card][:cvc],
            exp_month:  params[:card][:exp_month],
            exp_year:   "20#{params[:card][:exp_year]}".to_i
          }},
          {'X-Payjp-Direct-Token-Generate': 'true'} 
        )
        if token.blank?
          redirect_to new_card_path
        else
          customer = Payjp::Customer.create(card: token)
          card = Card.new(user_id: current_user.id, customer_id: customer.id, card_id: customer.default_card)
          if card.save
            redirect_to show_card_cards_path
          else
            redirect_to new_card_path
          end
        end
    end

    # これでカード登録機能が一通り完成したので、実際にカード登録→閲覧→削除→再登録の一通りの動作を確認しておきましょう。
    def destroy
        if Card.find_by(user_id: current_user.id).destroy
          redirect_to root_path
        else
          render :show_card
        end
      end
end
