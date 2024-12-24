$(".savingbook").click(function(e) {
    $(this).children('form').submit();
})
$('form').submit(function (event) {
    
});

Handlebars.registerHelper("log", function(something) {
    // console.log(something);
  });