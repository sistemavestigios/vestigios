module Batale::BlocsHelper
  def comment_icons(comment, _index)
    icons = ''
    if comment._parent.class != Excerpt
      icons += "<button class='mdl-list__item-secondary-action mdl-button mdl-button--icon mdl-js-button mdl-js-ripple-effect'
        onclick=" + "comment_comment('#{comment.id}')" + " id='tt-#{comment.id}-comment'>"
      icons += "<i class='material-icons' style='padding-right: 2px;'>message</i>"
      icons += '</button>'
      if current_user == comment.user
        icons += "<button class='mdl-list__item-secondary-action mdl-button mdl-button--icon mdl-js-button mdl-js-ripple-effect'
          onclick=" + "edit_comment('#{comment.id}')" + " id='tt-#{comment.id}-edit'>"
        icons += "<i class='material-icons' style='padding-right: 2px;'>edit</i>"
        icons += '</button>'
      end
    end
    if comment.child_comments?
      icons += "<button class='mdl-list__item-secondary-action mdl-button mdl-button--icon mdl-js-button mdl-js-ripple-effect'
        onclick=" + "list_comment_comments('#{comment.id}')" + " id='tt-#{comment.id}-info'>"
      icons += "<i class='material-icons' style='padding-right: 2px;'>info</i>"
      icons += '</button>'
    end
    if current_user == comment.user
      # icons += "<button class='mdl-list__item-secondary-action mdl-button mdl-button--icon mdl-js-button mdl-js-ripple-effect'
      #   onclick="+"edit_comment('#{comment.id}')"+" id='tt-#{comment.id}-edit'>"
      # icons += "<i class='material-icons' style='padding-right: 2px;'>edit</i>"
      # icons += "</button>"
      params = {}
      params[:id] = comment.id
      params[:parent_class] = comment._parent.class
      params[:parent_id] = comment._parent.id
      params[:grandparent_class] = comment._parent._parent.class unless comment._parent._parent.nil?
      params[:grandparent_id] = comment._parent._parent.id unless comment._parent._parent.nil?
      icons += link_to raw("<i class='material-icons' style='padding-right: 2px;'>delete</i>"),
        btoe_comment_path(params),
        class: 'mdl-list__item-secondary-action mdl-button mdl-button--icon mdl-js-button mdl-js-ripple-effect',
        id: "tt-#{comment.id}-delete",
        method: :delete,
        data: { confirm: 'Tem certeza que deseja deletar o comentário?' }
    end
    icons += "<div class='mdl-tooltip' data-mdl-for='tt-#{comment.id}-edit'>Editar Comentário</div>"
    icons += "<div class='mdl-tooltip' data-mdl-for='tt-#{comment.id}-delete'>Deletar Comentário</div>"
    icons += "<div class='mdl-tooltip' data-mdl-for='tt-#{comment.id}-info'>Comentários</div>"
    icons += "<div class='mdl-tooltip' data-mdl-for='tt-#{comment.id}-comment'>Comentar Comentário</div>"
    icons.html_safe
  end
end
