class TagsController < ApplicationController
    def show
        @articles = TagArticle.where(tag: params[:id])
    end
end
