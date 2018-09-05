module IconHelper
  CLASS = 'mdl-button mdl-button--icon mdl-js-button mdl-js-ripple-effect'.freeze

  def card_action_icons(show_path, edit_path, delete_path, message_confirm = t('links.confirm'))
    icons = ''
    id = show_path.id
    icons += show_icon(show_path)
    icons += edit_icon(edit_path, id) if edit_path.present?
    icons += delete_icon(delete_path, message_confirm) if delete_path.present?
    icons += icon_tooltips(id, show_path.class.model_name.human)
    icons.html_safe
  end

  def delete_icon(delete_path, message_confirm)
    link_to raw("<i class='material-icons' style='padding-right: 2px;'>delete</i>"),
      delete_path, class: CLASS, id: "#{delete_path.id}-btn-delete", method: :delete, data: { confirm: message_confirm }
  end

  def edit_icon(edit_path, id)
    link_to raw("<i class='material-icons' style='padding-right: 2px;'>edit</i>"),
      edit_path, class: CLASS, id: "#{id}-btn-edit", method: :get
  end

  def icon_tooltips(id, model_name)
    "<span class='mdl-tooltip mdl-tooltip--top' for='#{id}-btn-show' >Ver #{model_name}</span>" \
      "<span class='mdl-tooltip mdl-tooltip--top' for='#{id}-btn-edit' >Editar #{model_name}</span>" \
      "<span class='mdl-tooltip mdl-tooltip--top' for='#{id}-btn-delete' >Deletar #{model_name}</span>"
  end

  def show_icon(show_path)
    link_to raw("<i class='material-icons' style='padding-right: 2px;'>message</i>"),
      show_path, class: CLASS, id: "#{show_path.id}-btn-show", method: :get
  end
end
