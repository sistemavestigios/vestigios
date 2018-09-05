var Texts;

Texts = {
  associateColor: function(colorId) {
    var excerpts = Texts.getSelectedExcerpts();
    btpTextId = $('#btp_text_id').val();
    currentUserId = $('#current_user_id').val();
    updateColorUrl = $('#update_color_url').val();
    updateColorUrl += '/' + colorId;
    excerpts.forEach(function(e, i) {
      if (e != null) {
        $.ajax({
          url: updateColorUrl,
          type: 'PATCH',
          data: {
            btp_color: {
              excerpts_attributes: [{
                excerpt: e,
                text_id: btpTextId,
                user_id: currentUserId
              }]
            }
          },
        })
      }
    });
  },

  disableButtons: function() {
    $('#add_to_bloc')[0].disabled = true;
    $('#associate_color')[0].disabled = true;
  },

  enableButtons: function() {
    $('#add_to_bloc')[0].disabled = false;
    $('#associate_color')[0].disabled = false;
  },

  init: function() {
    $('#selected-text ul').click(function(event) {
      //quando clica na lista de trechos selecionados
      if ($(event.target).is('i.material-icons')) {
        //e o alvo foi o botão de deletar
        // i.material-icons -> button -> span -> li
        event.target.parentNode.parentNode.parentNode.replaceWith('');
        //pega o li que ele está contido e o deleta
        //se não sobrou nenhum trecho, coloca o placeholder de novo
        if ($('#selected-text ul').children().size() == 0) {
          $('#selected-text p').html('Selecione o trecho no texto acima e clique em \"Enviar Seleção\"');
        }
        Texts.disableButtons();
      }
    });

    document.onselectionchange = function() {
      var selection = document.getSelection();
      if ($('.selection-bttn')[0]) {
        $('.selection-bttn')[0].disabled = (selection.toString() != '') ? false : true
      }
    };
  },

  getSelectionText: function() {
    var text = '';
    if (window.getSelection) {
      text = window.getSelection().toString();
    } else if (document.selection && document.selection.type != 'Control') {
      text = document.selection.createRange().text;
    }

    if (text != '') {
      $('#selected-text p').text('Trechos a serem adicionados');
      $('#selected-text ul').append(
        '<li class=\'mdl-list__item\'>' +
        '<span class=\'mdl-list__item-primary-content\'>' + text + '</span>' +
        '<span class=\'mdl-list__item-secondary-action\'>' +
        '<button class=\'mdl-button mdl-js-button mdl-button--icon mdl-button--colored\'>' +
        '<i class=\'material-icons\'>cancel</i>' +
        '</button></span></li>');
      showSnackBar('Trecho selecionado');
      Texts.enableButtons();
    } else {
      $('#selected-text p').html('Selecione o trecho no texto acima e clique em \"Enviar Seleção\"');
      showSnackBar('Trecho inválido. Selecione algum trecho');
    }
  },

  getSelectedExcerpts: function() {
    excerpts = [];
    //pega o conteudo do ul, os li
    $('#selected-text ul').children().each(function() {
      //e adiciona a trechos o conteudo do primeiro filho do li (um span o trecho de fato)
      excerpts.push($(this).children()[0].innerHTML.trim());
    });
    return excerpts;
  },

  saveToBloc: function(blocId) {
    var excerpts = Texts.getSelectedExcerpts();
    btpTextId = $('#btp_text_id').val();
    currentUserId = $('#current_user_id').val();
    updateBlocUrl = $('#update_bloc_url').val();
    updateBlocUrl += '/' + blocId;
    excerpts.forEach(function(e, i) {
      if (e != null) {
        $.ajax({
          url: updateBlocUrl,
          type: 'PATCH',
          data: {
            btp_bloc: {
              excerpts_attributes: [{
                excerpt: e,
                text_id: btpTextId,
                user_id: currentUserId
              }]
            }
          },
        })
      }
    });
  }
}

window.Texts = Texts;
