// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or any plugin's vendor/assets/javascripts directory can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// compiled file. JavaScript code in this file should be added after the last require_* statement.
//
// Read Sprockets README (https://github.com/rails/sprockets#sprockets-directives) for details
// about supported directives.
//
//= require material
//= require jquery
//= require jquery_ujs
//= require jquery-minicolors
//= require select2
//= require select2/i18n/pt-BR.js
//= require chartkick
//= require_tree .

function bindAccordion() {
  $('h6.accordion').click(function() {
    $(this).parent().find('div.accordion').slideToggle("fast", "swing", function() {});
    $(this).hasClass('active') ? $(this).removeClass('active') : $(this).addClass('active')
  });
}

function bindButtonToDialog() {
  $('.js-button').each(function(index, button) {
    var dialog = $('#dialog_' + button.id)[0];
    $(button).click(function() {
      dialog.showModal();
    });
    closeDialogButton = $(dialog.querySelector('.close'));
    closeDialogButton.click(function() {
      dialog.close();
      //depois de fechar o dialog, o scroll fica bugado enquanto nao redimensiona a tela
      // no firefox funciona sem isso, no chrome não, veja só
      //work arround is here!
      document.querySelector('.mdl-layout__content').style.overflowX = 'auto';
      document.querySelector('.mdl-layout__content').style.overflowX = '';
      //work arround done!
    });
  });
}

function clearFields() {
  $('.mdl-textfield input').each(function() {
    $(this).val('');
    $(this).parent().removeClass('is-dirty')
  })
  $('.mdl-grid select').each(function() {
    $(this).val([]).trigger('change');
  });
}

function expandSearch() {
  var botao = $('#button_expand_search');
  var div_advanced_search = $('#advanced_search');
  botao.empty();
  div_advanced_search.slideToggle('fast');
  if (div_advanced_search.hasClass('active')) {
    div_advanced_search.removeClass('active');
    botao.html('Busca Avançada');
  } else {
    div_advanced_search.addClass('active');
    botao.html('Ocultar opções');
  }
}

function toggleNested() {
  $('.toggle').click(function(e) {
    const iconEl = e.target.querySelector('i#changeable-icon');

    iconEl.innerText = iconEl.innerText == 'expand_more' ?
      'remove' :
      'expand_more';

    var $this = $(this);

    $this.toggleClass('show');

    if ($this.next().hasClass('show')) {
      $this.next().removeClass('show');
      $this.next().slideUp(200);
    } else {
      $this.next().addClass('show');
      $this.next().slideDown(200);
    }
  });
}

function searchOnSelectChange() {
  $('.mdl-grid select').each(function(index, e) {
    $(e).on('change', function() {
      $('#search-form').submit();
    });
  });
}

function showSnackBar(message) {
  var notification = $('.mdl-snackbar')[0];
  var data = { message: message, timeout: 1500 };
  notification.MaterialSnackbar.showSnackbar(data);
}

$(document).ready(function() {
  Texts.init();
  // Sets every select on document to select2
  $('select').select2({
    width: 'auto',
    language: 'pt-BR'
  });

  $('#per_page').change(function() {
    if (this.value) {
      $('#search-form').submit();
    }
  });
  // setting minicolor
  $('#input_hex_color').minicolors({
    inline: true
  });
  // Calls bindAccordion on first page load
  bindAccordion();
  bindButtonToDialog();
  toggleNested();
  searchOnSelectChange();
});

$(document).ajaxComplete(function() {
  bindAccordion();
  bindButtonToDialog();
  toggleNested();
});

Chartkick.configure({language: "pt-br"});
