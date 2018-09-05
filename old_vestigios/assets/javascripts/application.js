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
//= require turbolinks
//= require jquery.minicolors

//= require chartkick
//= require_tree .

// require jquery.minicolors é pro colorpicker, talvez fosse melhor não adicionar
// direto aqui, por aparecer em todas as paginas se estiver aqui
// talvez fosse melhor adicionar só onde ele é utilizado

// mesma coisa com o require Chart.bundle e o require chartkick


// Código recomendado pela documentação para funcionar junto com o Turbolinks.
// Precisamos? Sim
document.addEventListener('turbolinks:load', function() {
  componentHandler.upgradeDom();
});

// Função para abrir ou fechar o drawer menu, caso alguém venha a precisar
var toggle_drawer = function() {
  //$(".mdl-layout__drawer").toggleClass("is-visible");
  var d = document.querySelector('.mdl-layout');
  d.MaterialLayout.toggleDrawer();
}

// Função para esconder o spinner
var hide_spinner = function(){
  $("#spinner").removeClass("is-active");
  $("#spinner").css("display", "none"); // apenas remover is-active não o esconde
}
// e a função para mostrá-lo
var show_spinner = function(){
  $("#spinner").addClass("is-active"); // É necessário dizer que está ativo
  $("#spinner").css("display", "inline"); // E restaurar o display padrão
}

// função para registrar todos os dialogs existentes no polyfill
// e torná-los utilizáveis para outros navegadores além do Chrome
var register_dialogs_to_dialogs_polyfill = function(){
  var dialogs = $("dialog");
  dialogs.each(function(index){
    var dialog = $( this )[0];
    if (! dialog.showModal) {
      dialogPolyfill.registerDialog(dialog);
    }
  });
}

$( document ).ready(function() {
  // ao terminar de carregar a pagina, registra os dialogs existentes
  // o custo não parece grande,
  // apenas uma busca por um tipo de elemento praticamente, se não existir nenhum na página
  // possivel otimização seria rodar isso somente nas páginas que de fato usam dialogs
  register_dialogs_to_dialogs_polyfill();
});

// Função para adicionar a um botão o evento de abrir um dialog ao click
// assim como vincular a classe .close de um botão no dialog ao evento de fechar
// id_dialog -> id do dialog que vai ser mostrado,
//              espera-se que tenha um botão com a classe .close
// id_button -> id do botão que chamará o dialog. Não precisa necessariamente
//              ser um button, pode ser um li de um menu, por exemplo
var register_show_dialog_event = function(id_dialog, id_button){
  var dialog = $("#" + id_dialog)[0];
  var button = $("#"+id_button)[0];
  button.addEventListener('click', function() {
    dialog.showModal();
    $(".custom-menu").hide(100);
  });
  dialog.querySelector('.close').addEventListener('click', function() {
    dialog.close();
    //depois de fechar o dialog, o scroll fica bugado enquanto nao redimensiona a tela
    // no firefox funciona sem isso, no chrome não, veja só
    //work arround is here!
    document.querySelector('.mdl-layout__content').style.overflowX = 'auto';
    document.querySelector('.mdl-layout__content').style.overflowX = '';
    //work arround done!

  });
}

var fechar_dialog = function(dialog_id){
  $("#" + dialog_id)[0].close();
}

var bind_accordion = function(){
  $('h6.accordion').click(function(){
    $(this).parent().find('div.accordion').slideToggle("fast","swing",function(){});
    if ($(this).hasClass('active')){
      $(this).removeClass('active');
    }
    else {
      $(this).addClass("active");
    }
  });
}

//função para os errortogs aninhados
var toggle_nested = function() {
  $('.toggle').click(function(e) {
      // e.preventDefault(); Comentado pro link poder funcionar

      const iconEl = e.target.querySelector('i#changeable-icon');

      iconEl.innerText = iconEl.innerText == 'expand_more'
        ? 'remove'
        : 'expand_more';

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

// função para AJAXs
var ajax = function(options) {
  $.ajax({
    type: options['type'],
    url: options['url'],
    data: options['data'],
    success:function(data, textStatus, jqXHR){
      notification = document.querySelector('.mdl-snackbar');
      data = {message: options['success'], timeout: 3000};
      notification.MaterialSnackbar.showSnackbar(data);
      location.reload(true);
    },
    error:function(jqXHR, textStatus, errorThrown){
      console.log(jqXHR);
      console.log(textStatus);
      console.log(errorThrown);
      notification = document.querySelector('.mdl-snackbar');
      data = {message: options['error'], timeout: 3000};
      notification.MaterialSnackbar.showSnackbar(data);
    }
  });
}

Chartkick.configure({language: "pt-br"});
