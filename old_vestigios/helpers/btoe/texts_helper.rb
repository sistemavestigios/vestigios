module Btoe::TextsHelper
  # Cria um dialog contendo uma lista das palavras passadas e um checkbox para seleciona-la
  # Params
  # - palavras: Array com as palavras
  # - id = String com o id do dialog
  def dialog_desassociar_cores(associacoes, id)
    excerpts_ids = []
    retorno = ''
    retorno += "<dialog id='dialog-cores-#{id}' class='mdl-dialog'style='width: 60%;'>
      <h5 class='mdl-dialog__title'>Desassociar cor: </h5>
      <div class='mdl-dialog__content'>
        <ul class='demo-list-control mdl-list'>"
    associacoes.each do |associacao|
      excerpts_ids << associacao.id.to_s
      retorno += "
    <li class='mdl-list__item'>
      <span class='mdl-list__item-primary-content'>
        <i class='material-icons  mdl-list__item-avatar'>bookmark_border</i>#{associacao.trecho}
      </span>
      <span class='mdl-list__item-secondary-action'>
        <label class='mdl-checkbox mdl-js-checkbox mdl-js-ripple-effect' for='list-checkbox-#{associacao.id}'>
          <input type='checkbox' id='list-checkbox-#{associacao.id}' class='mdl-checkbox__input'/>
        </label>
      </span>
    </li>"
    end
    retorno += "
  </ul>
</div>
<div class='mdl-dialog__actions'>
  <button type='button' class='mdl-button mdl-button--colored mdl-js-button mdl-js-ripple-effect'
           onclick='deletarAssociacoes(#{excerpts_ids},\"#{id}\")'>
    Desassociar
  </button>
  <button type='button' class='close mdl-button mdl-button--colored mdl-js-button mdl-js-ripple-effect' >
    Cancelar
  </button>
</div>
    </dialog>"
    retorno.html_safe
  end
end
