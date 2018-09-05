var init_btoe_bloc_search;
init_btoe_bloc_search = function(){
  $('#btoe_bloc-search-form').on("ajax:before", function(event, data, status){
    $('#btoe_bloc-search-errors').empty();
    show_spinner();
  });

  $('#btoe_bloc-search-form').on("ajax:complete", function(event, data, status){
    hide_spinner();
  });

  $('#btoe_bloc-search-form').on('ajax:error', function(event, xhr, status, error){
    console.log(error);
    hide_spinner();
    $('#pagination-itens').html(" ");
    $('#btoe_bloc-search-errors').html("Ocorreu um erro ao buscar.");
  });
}

$(document).ready(function(){
  init_btoe_bloc_search();
});
