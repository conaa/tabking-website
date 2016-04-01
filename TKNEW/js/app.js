$(document).foundation();
 $(function(){
      $(".typer").typed({
        strings: ["mobile app", "web app", "software", "website"],
        typeSpeed: 140
      });
  });

$('#services').click(function(){
  
    $('.simple-dropdown-bar').slideToggle();
});