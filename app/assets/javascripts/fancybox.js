
function openFancybox(){
    jQuery(this).trigger("click");
}
function closeFancybox(){
    jQuery.fancybox.close();
}


jQuery(document).ready(function() {
    jQuery("a#single_image").hoverIntent({
        sensitivity: 7,
        interval:500,
        timeout:0,
        over: openFancybox,
        out: closeFancybox
    }); // hoverIntent


    /* This is basic - uses default settings */
        $('a#single_image').lightBox();

    //    jQuery("a#single_image").fancybox({
    //        //        'titleShow'		: false,
    //        //        'transitionIn'	: 'elastic',
    //        //        'transitionOut'	: 'elastic',
    //        'overlayShow' : false,
    //        'autoScale'   : true
    //    });

    /* Using custom settings */

    jQuery("a#inline").fancybox({
        'hideOnContentClick': true
    });

    jQuery("a[rel=image_group]").fancybox({
        'transitionIn'		: 'none',
        'transitionOut'		: 'none',
        'titleShow'		: false
    });
});
