module ApplicationHelper
  def create_dialog_definition(id, title, inputs)
    dialog = ''
    dialog += "<dialog id=#{id} class='mdl-dialog' style='width: 60%;'>"
    dialog += "<h5 class='mdl-dialog__title'>#{title}</h5>"
    dialog += "<div class='mdl-dialog__content'>"
    dialog += create_inputs inputs
    dialog += '</div>'
    dialog += '<h6>Campos com * são obrigatórios</h6>'
    dialog += "<div class='mdl-dialog__actions'>
                <button type='button' id='dialog_definition_bttn' class='mdl-button mdl-button--colored mdl-js-button mdl-js-ripple-effect' onclick='createDefinition()' disabled>
                  Adicionar
                </button>
                <button type='button' class='close mdl-button mdl-button--colored mdl-js-button mdl-js-ripple-effect'
                onclick='clearDialog();'>
                  Cancelar
                </button>
              </div>"
    dialog += '</dialog>'
    dialog.html_safe
  end

  def create_inputs(names)
    inputs = ''
    names.each do |name|
      inputs += "<div class='mdl-textfield mdl-js-textfield mdl-textfield--floating-label full_size'>
                  <input class='mdl-textfield__input' type='text' id='#{name}'></input>
                  <label class='mdl-textfield__label' for='#{name}'>#{name.tr('_', ' ') + '*'}</label>
                </div>"
    end
    inputs.html_safe
  end

  def create_checkbox_inputs(hash_id_label)
    checkboxes = ''
    hash_id_label.each do |id, label|
      checkboxes += "<li style='height: 110px' class='mdl-list__item'>"
      checkboxes += "<span class='mdl-list__item-secondary-action'>"
      checkboxes += "<label for='#{id}' class='mdl-checkbox mdl-js-checkbox'>"
      checkboxes += "<input type='checkbox' id='#{id}' class='mdl-checkbox__input checkbox' checked>"
      checkboxes += "<span class='mdl-checkbox__label'>#{label}</span>"
      checkboxes += '</label></span></li>'
    end
    checkboxes.html_safe
  end

  def create_dialog_new_definition(id, title, inputs, errortogs)
    dialog = ''
    dialog += "<dialog id=#{id} class='mdl-dialog' style='width: 60%;'>"
    dialog += "<h5 class='mdl-dialog__title'>#{title}</h5>"
    dialog += "<div class='mdl-dialog__content'>"
    dialog += "Categoria*:&emsp;<select id='select_categoria'>"
    dialog += '<option selected></option>'
    errortogs.each do |errortog|
      dialog += "<option value='#{errortog.id}'>#{errortog.name}</option>"
    end
    dialog += '</select>'
    dialog += create_inputs inputs
    dialog += '</div>'
    dialog += '<h6>Campos com * são obrigatórios</h6>'
    dialog += "<div class='mdl-dialog__actions'>
                <button type='button' id='dialog_definition_bttn' class='mdl-button mdl-button--colored mdl-js-button mdl-js-ripple-effect' onclick='createDefinition()'disabled>
                  Adicionar
                </button>
                <button type='button' class='close mdl-button mdl-button--colored mdl-js-button mdl-js-ripple-effect'
                onclick='clearDialog();'>
                  Cancelar
                </button>
              </div>"
    dialog += '</dialog>'
    dialog.html_safe
  end

  def create_card_action_icons(show_path, edit_path, delete_path, message_alert = 'Are you sure?')
    icons = ''
    # id = show_path.class == String ? show_path.html_safe : show_path.id.to_s
    id = (rand * 10_000_000).to_i.to_s

    icons += link_to raw("<i class='material-icons' style='padding-right: 2px;'>message</i>"),
      show_path,
      class: 'mdl-button mdl-button--icon mdl-js-button mdl-js-ripple-effect',
      id: id + '-btn-show',
      method: :get
    icons += link_to raw("<i class='material-icons' style='padding-right: 2px;'>edit</i>"),
      edit_path,
      class: 'mdl-button mdl-button--icon mdl-js-button mdl-js-ripple-effect',
      id: id + '-btn-edit',
      method: :get
    icons += link_to raw("<i class='material-icons' style='padding-right: 2px;'>delete</i>"),
      delete_path,
      class: 'mdl-button mdl-button--icon mdl-js-button mdl-js-ripple-effect',
      id: id + '-btn-delete',
      method: :delete, data: { confirm: message_alert }

    icons += "<span class='mdl-tooltip mdl-tooltip--top' for='#{id}-btn-show' >Ver</span>"
    icons += "<span class='mdl-tooltip mdl-tooltip--top' for='#{id}-btn-edit' >Editar</span>"
    icons += "<span class='mdl-tooltip mdl-tooltip--top' for='#{id}-btn-delete' >Deletar</span>"
    icons.html_safe
  end

  def comment_dialog(id, title, textarea_id, bttn_id)
    dialog = "<dialog id='#{id}' class='mdl-dialog' style='width: 60%;'>"
    dialog += "<h5 class='mdl-dialog__title'>#{title}</h5>"
    dialog += "<div class='mdl-dialog__content'>
                <div class='mdl-textfield mdl-js-textfield mdl-textfield--floating-label full_size'>
                  <textarea class='mdl-textfield__input' type='text' id='#{textarea_id}'></textarea>
                  <label class='mdl-textfield__label' for='#{textarea_id}'>Comentário</label>
                </div>
              </div>"
    dialog += "<div class='mdl-dialog__actions'>
                <button type='button' class='mdl-button mdl-button--colored mdl-js-button mdl-js-ripple-effect' id=#{bttn_id} disabled>
                    Salvar
                </button>
                <button type='button' class='close mdl-button mdl-button--colored mdl-js-button mdl-js-ripple-effect'
                  onclick=" + "fechar_dialog('#{id}')" + ">
                    Cancelar
                </button>
              </div>"
    dialog += '</div>'
    dialog.html_safe
  end

  def list_comments_dialog(id, title, comments)
    dialog = "<dialog id='#{id}' class='mdl-dialog' style='width: 60%;'>
                <h5 class='mdl-dialog__title'>#{title}</h5>"
    dialog += "<div class='mdl-dialog__content'>"
    comments.each do |comment|
      comment_id = comment.parent_comment? ? comment.parent_comment.id : comment._parent.id
      dialog += "<span class='comment' id='#{comment_id}'>
                  <strong> Comentário de #{comment.user.full_name}: </strong>
                    #{comment.comment}
                  <br>
                </span>"
    end
    dialog += '</div>'
    dialog += "<div class='mdl-dialog__actions'>
                <button type='button' class='mdl-button mdl-button--colored mdl-js-button mdl-js-ripple-effect close' onclick=" + "fechar_dialog('#{id}')" + ">Ok</button>
              </div>"
    dialog += '</dialog>'
    dialog.html_safe
  end
end
