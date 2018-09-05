var init_batale_bloc_search;
init_batale_bloc_search = function(){
  $('#batale_bloc-search-form').on("ajax:before", function(event, data, status){
    $('#batale_bloc-search-errors').empty();
    show_spinner();
  });

  $('#batale_bloc-search-form').on("ajax:complete", function(event, data, status){
    hide_spinner();
  });

  $('#batale_bloc-search-form').on('ajax:error', function(event, xhr, status, error){
    console.log(error);
    hide_spinner();
    $('#pagination-itens').html(" ");
    $('#batale_bloc-search-errors').html("Ocorreu um erro ao buscar.");
  });
}

$(document).ready(function(){
  init_batale_bloc_search();
});
