// 3~5行目が重要です。3行目はbodyというクラス名の要素に文字が入力(keyup)されたら関数を実行しろ、という記述です。実行する関数は4行目にあり、previewというidを持つ要素の中身(val)に、this(=bodyクラス)の中身(val)を入れろという記述になっています。これにより、以下のような感じで左側の入力欄(body)にいれた情報が右側のプレビュー(preview)に反映されるようになります。
// 4~8行目の記述によってコントローラのmarkdownメソッドが起動し、markdownメソッドが起動するとmarkdown.json.builderが起動してjsonの中身をJavaScriptに渡し、そしてJavaScriptの9~11行目でプレビューにマークダウン変換された内容を反映する、という流れになっています。
document.addEventListener("turbolinks:load", function(){
    $(function(){
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
      })
        //   14~16行目を追加しました。意外にもたった3行で記述できます。${window.URL.createObjectURL(e.target.files[0])}という記述が割と複雑ですが、とにかくこれを書けばfileタイプのinputで選択した画像のアドレスを取得できるんだなーくらいに考えてしまっていいと思います。
      $("#article_thumbnail").on("change", function(e){
          $(".thumbnail").css("background-image",`url(${window.URL.createObjectURL(e.target.files[0])})`);
      })
    })
  })