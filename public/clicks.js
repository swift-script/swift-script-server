$(document).ready(function(){

$('#button').on('click', function() {
	console.log($("#inputfield").val());
    $.post( "/", $("#inputfield").val(), function(data) {
    	$('#right').text(data);	
    });	
});
});