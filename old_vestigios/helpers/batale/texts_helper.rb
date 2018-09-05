module Batale::TextsHelper
  # Cria um dialog contendo uma lista das palavras passadas e um checkbox para seleciona-la
  # Params
  # - palavras: Array com as palavras
  # - id = String com o id do dialog
  def dialog_palavras(palavras, id)
    retorno = ''
    retorno += "<dialog id='dialog-palavras-#{id}' class='mdl-dialog'style='width: 60%;'>
      <h5 class='mdl-dialog__title'>Desassociar palavra: </h5>
      <div class='mdl-dialog__content'>
        <ul class='demo-list-control mdl-list'>"
    palavras.each do |palavra|
      retorno += "
    <li class='mdl-list__item'>
      <span class='mdl-list__item-primary-content'>
        #{palavra.wrong}
      </span>
      <span class='mdl-list__item-secondary-action'>
        <label class='mdl-checkbox mdl-js-checkbox mdl-js-ripple-effect' for='#{id}-#{palavra.tag_id}'>
          <input type='checkbox' id='#{id}-#{palavra.tag_id}' class='mdl-checkbox__input'/>
        </label>
      </span>
    </li>"
    end
    retorno += "
  </ul>
</div>
<div class='mdl-dialog__actions'>
  <button type='button' class='mdl-button mdl-button--colored mdl-js-button mdl-js-ripple-effect'
           onclick='desassociarPalavras(\"#{id}\")'>
    Desassociar
  </button>
  <button type='button' class='close mdl-button mdl-button--colored mdl-js-button mdl-js-ripple-effect' onclick='this.parentNode.parentNode.close()' >
    Cancelar
  </button>
</div>
    </dialog>"
    retorno.html_safe
  end
end
