//var windowIsNearTop = true;

$(document).scroll(function(){
	if ($(document).scrollTop() < 200){
		$($('.masthead-brand')[0]).fadeOut(200);
	} else {
		$($('.masthead-brand')[0]).fadeIn(200);
	}
});