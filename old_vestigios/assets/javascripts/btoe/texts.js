var init_btoe_text_search;
init_btoe_text_search = function(){
  $('#btoe_text-search-form').on("ajax:before", function(event, data, status){
    $('#btoe_text-search-errors').empty();
    show_spinner();
  });

  $('#btoe_text-search-form').on("ajax:complete", function(event, data, status){
    hide_spinner();
  });

  $('#btoe_text-search-form').on('ajax:error', function(event, xhr, status, error){
    console.log(error);
    hide_spinner();
    $('#pagination-itens').html(" ");
    $('#btoe_text-search-errors').html("Ocorreu um erro ao buscar.");
  });
}

$(document).ready(function(){
  init_btoe_text_search();
});
