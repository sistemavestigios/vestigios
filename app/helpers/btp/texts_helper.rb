module Btp::TextsHelper
  def new_li_bloc(bloc)
    li = "<li><strong>Bloco:</strong> #{bloc.name} <br><strong>Descrição:</strong>#{bloc.description}<br><strong>"
    li +=  link_to 'Ir para lá', bloc
    li += '</strong></li>'
    li.html_safe
  end
end
