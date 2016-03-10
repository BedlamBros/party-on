//var windowIsNearTop = true;

$(document).scroll(function(){
	if ($(document).scrollTop() < 200){
		$($('.masthead-brand')[0]).fadeOut(200);
		$($('.masthead-brand')[0]).css('display', 'none');
	} else {
		$($('.masthead-brand')[0]).css('display', 'inline');
		$($('.masthead-brand')[0]).fadeIn(200);
	}
});