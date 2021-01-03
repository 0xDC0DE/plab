$("#arrow").click(function() {
    var content = $("a[name='content']");

    $('html,body').animate({scrollTop: content.offset().top}, 'slow');
})