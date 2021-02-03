// 3~5行目が重要です。3行目はbodyというクラス名の要素に文字が入力(keyup)されたら関数を実行しろ、という記述です。実行する関数は4行目にあり、previewというidを持つ要素の中身(val)に、this(=bodyクラス)の中身(val)を入れろという記述になっています。これにより、以下のような感じで左側の入力欄(body)にいれた情報が右側のプレビュー(preview)に反映されるようになります。
// 4~8行目の記述によってコントローラのmarkdownメソッドが起動し、markdownメソッドが起動するとmarkdown.json.builderが起動してjsonの中身をJavaScriptに渡し、そしてJavaScriptの9~11行目でプレビューにマークダウン変換された内容を反映する、という流れになっています。
document.addEventListener("turbolinks:load", function(){
    // これで画像を挿入ボタンが復活です。続けて、コントローラのeditアクションを作成しましょう。

    // 3~8行目を追加、14行目・40~41行目を編集しました。3~8行目では、articlesコントローラとdraftsコントローラとで内容が変化するtargetModelという変数を定義しています。このtargetModelを14行目・40~41行目で使用することにより、画像の入力欄をarticlesとdraftsで分けることができます。
    $(function(){
      var actionName = $("#header").attr("action");
      if(actionName == "articles#new" || actionName == "articles#edit"){
        var targetModel = "article";
      }else if(actionName == "drafts#edit"){
        var targetModel = "draft";
      }
      if(actionName == "articles#edit" || actionName == "drafts#edit"){
        $(".thumbnail").css("background-image",`url(${$("#header").attr("thumbnail")})`);
        $(".bottom-wrapper").prepend(`
          <label class="image_fields">
            <div class="image-button">画像を挿入</div>
            <input type="file" name="${targetModel}[images_attributes][0][image]" id="${targetModel}_images_attributes_0_image">
          </label>
        `);
      }
      // if($("#header").attr("action") == "articles#edit"){
      //   $(".thumbnail").css("background-image",`url(${$("#header").attr("thumbnail")})`);
      //   $(".bottom-wrapper").prepend(`
      //     <label class="image_fields">
      //       <div class="image-button">画像を挿入</div>
      //       <input type="file" name="draft[images_attributes][0][image]" id="draft_images_attributes_0_image">
      //     </label>
      //   `);
      // }

      // しかし、この記述はarticlesコントローラのための記述なので、これをdraftsコントローラ用に修正する必要があります
      // <input type="file" name="article[images_attributes][0][image]" id="article_images_attributes_0_image">

      $(".body").on("keyup", function(){
        $.ajax({
            url: "/articles/markdown",
            type: "post",
            data: {body: $(this).val()},
            dataType: "json"
        }).done(function(json){
            $("#preview").empty();
            $("#preview").append(json.body);
        })
      });

      // これでページを読み込んだ瞬間に1度だけbuildPreviewが実行され、プレビューを表示できます。
      // buildPreview();

      //   14~16行目を追加しました。意外にもたった3行で記述できます。${window.URL.createObjectURL(e.target.files[0])}という記述が割と複雑ですが、とにかくこれを書けばfileタイプのinputで選択した画像のアドレスを取得できるんだなーくらいに考えてしまっていいと思います。
      $("#article_thumbnail").on("change", function(e){
          $(".thumbnail").css("background-image",`url(${window.URL.createObjectURL(e.target.files[0])})`);
      })

      // var buildPreview = function(){
      //   $.ajax({
      //     url:  "/articles/markdown",
      //     type: "post",
      //     data: {body: $(".body").val()},
      //     dataType: "json"
      //   }).done(function(json){
      //     $("#preview").empty();
      //     $("#preview").append(json.body);
      //   })
      // };
      // buildPreview();
      // $(".body").on("keyup", function(){
      //   buildPreview();
      // })
      // $(".input-thumb").on("change", function(e){
      //   $(".thumbnail").css("background-image",`url(${window.URL.createObjectURL(e.target.files[0])})`);
      // })

      //   17~22行目を追加しました。これらの記述はいずれも「画像の入力欄を増やす」ということが目的です。画像が選ばれてimage_fieldsというクラスが割り当てられたlabel要素に変更がある度に、画像の入力欄が1つずつ増えていきます。

      // 「画像の入力欄」というのはinput要素にtype=fileを指定すると現れる「ファイルを選択選択されていません」というアレです。articles_new.scssの記述でdisplay:none;にして意図的に非表示にしていますが、これを切ると以下のように表示されます。
      //   var targetIndex = 0;
      //   $(`.image_fields`).on("change", function(){
      //     targetIndex ++;
      //     $(this).attr("for", `article_images_attributes_${targetIndex}_image`);
      //     $(this).append(`<input type="file" name="article[images_attributes][${targetIndex}][image]" id="article_images_attributes_${targetIndex}_image">`);
      //   });

      // if($("#header").attr("action") == "articles#edit"){
      //   $(".thumbnail").css("background-image",`url(${$("#header").attr("thumbnail")})`);
      // }

      // このtargetModelを14行目・40~41行目で使用することにより、画像の入力欄をarticlesとdraftsで分けることができます
      // $(this).attr("for", `${targetModel}_images_attributes_${targetIndex}_image`);
      // $(this).append(`<input type="file" name="${targetModel}[images_attributes][${targetIndex}][image]" id="${targetModel}_images_attributes_${targetIndex}_image">`);

      // 46~53行目を追加しました。まず46行目で下書きボタンのクリックイベントを拾います。下書きボタンがクリックされると、本来であればすぐにフォームが送信され、articles#createが実行されてしまいます。しかし、このままarticles#createが実行されると、記事が投稿されてしまい下書き保存できません。なので、ボタンがクリックされた直後に「フォームの送信を阻止」する必要があります。47行目の「e.preventDefault()」が、フォーム送信を阻止するための記述です。
      // 48~52行目では非同期通信を使ってset_draftという自作メソッドを実行します。set_draftはまだ定義していませんが、このあと「処理を分岐させるためのメソッド」として作成します。そしてこの実行後、51行目の記述によってフォームを送信します。
      $("#draft").on("click", function(e){
        e.preventDefault();
        $.ajax({
          url: "/articles/set_draft"
        }).done(function(){
          $("#article_form").submit();
        })
      })

      // 60~72行目を追加しました。この記述でlikeアクションを実行できます。
      $("#like-button").on("click", function(){
        $.ajax({
          url:  $(this).attr("action"),
          type: "get"
        }).done(function(json){
          if(json.flag){
            $("#like-text").text("いいね！");
          }else{
            $("#like-text").text("いいね済");
          }
          $("#like-number").text(json.like);
        })
      })
    })
  })