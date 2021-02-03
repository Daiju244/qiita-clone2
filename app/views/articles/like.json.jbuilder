json.like @article.likes.count
if Like.find_by(article_id: @article.id, user_id: current_user.id) == nil
    json.flag true
else
    json.flag false
end