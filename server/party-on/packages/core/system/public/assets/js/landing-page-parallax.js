var scrollIndex = 0; //0 is top of the screen, 1 is the next content pane, etc.
var s = skrollr.init();

skrollr.menu.init(s, {
    //skrollr will smoothly animate to the new position using `animateTo`.
    animate: true,

    //The easing function to use.
    easing: 'sqrt',

    //Multiply your data-[offset] values so they match those set in skrollr.init
    scale: 2,

    //How long the animation should take in ms.
    duration: function(currentTop, targetTop) {
        //By default, the duration is hardcoded at 500ms.
        return 500;

        //But you could calculate a value based on the current scroll position (`currentTop`) and the target scroll position (`targetTop`).
        //return Math.abs(currentTop - targetTop) * 10;
    },
    updateUrl: false
});
var NUM_SECTIONS = 2;
//some scrolling event handlers
var homeLink = document.getElementById('home-link');
var workLink = document.getElementById('work-link');
var contactLink = document.getElementById('contact-link');
var menuLinks = [];
menuLinks[0] = homeLink;
menuLinks[1] = workLink;
menuLinks[2] = contactLink;

$('.down-arrow').on('click', function() {
    scrollIndex++;
    switch (scrollIndex) {
        case 0:
            homeLink.click();
            break;
        case 1:
            workLink.click();
            break;
        case 2:
            contactLink.click();
            break;
    }
});
$('.up-arrow').on('click', function() {
    scrollIndex--;
        switch (scrollIndex) {
        case 0:
            homeLink.click();
            break;
        case 1:
            workLink.click();
            break;
        case 2:
            contactLink.click();
            break;
    }
});

$('.nav li a').on('click', function(e) {
    var selectedA = $('.selected')[0];
    $(selectedA).removeClass('selected');
    $(e.target).addClass('selected');
});

$('.up-arrow').on('click', setArrowVisibility);
$('.down-arrow').on('click', setArrowVisibility);

function setArrowVisibility(e){
    var upA = $('.up-arrow')[0];
    var downA = $('.down-arrow')[0];
    if (scrollIndex == 0) {
        $(upA).css('display', 'none');
    } else {
        $(upA).css('display', 'block');
    }
    if (scrollIndex == NUM_SECTIONS) {
        $(downA).css('display', 'none');
    } else {
        $(downA).css('display', 'block');
    }
    if (scrollIndex != NUM_SECTIONS && scrollIndex != 0) {
        upA.css('display', 'block');
        downA.css('display', 'block');
    }
}

$(document).ready(function() {
    setArrowVisibility();
});