var state = 'EULA';
var eula_text = '<h3>End-User License Agreement</h3><br />Culture Page, LLC does not endorse or promote underage drinking or any use or distribution of any contraband substance. Culture Page, LLC is not liable for any damages, injuries, death or any other forms of legal liability.  Any illegal action that takes place outside of this application are neither controlled nor endorsed by Culture Page LLC.';
var privacy_text = '<h3>Privacy Policy</h3><br />By submitting content through this application you are agreeing to the Terms of Use for this service. All information submitted to this app is to be considered public and viewable by all users. This service does not use any personal data provided by Facebook nor does it share user submitted content with Facebook. By authorizing this service to use your Facebook account for your user identity, you are agreeing to Facebook\'s terms of use and privacy policy as well.';
var terms_text = '<h3>Terms of Use</h3><br />By submitting any information directly or indirectly to Culture Page, LLC through the use of this service, users are agreeing to our Privacy Policy and Terms of Service. You agree that you are responsible for all data charges you incur by using this service. By agreeing to our terms and conditions, users give up the right to sue Culture Page, LLC or take any form of legal action against Culture Page LLC or Culture Page, LLC employees. All forms of communication, information, personal information passed along, shared, or distributed using this service is at your own risk and is not endorsed by Culture Page, LLC. You are solely responsible for the content and information you post or upload on the Service whether submitted publicly or privately. You may not post as part of the Service, or transmit to the company in any way, any offensive, inaccurate, incomplete, abusive, obscene, profane, threatening, intimidating, harassing, racially offensive, or illegal material.';

function setLegalContainerText() {
	console.log(state);
	switch (state) {
		case 'EULA':
			$('#legal-text-container').html(eula_text);
			$($('.pagination li')[0]).toggleClass('active');
			break;
		case  'Privacy Policy':
			$('#legal-text-container').html(privacy_text);
			$($('.pagination li')[1]).toggleClass('active');
			break;
		case 'Terms of Use':
			$('#legal-text-container').html(terms_text);
			$($('.pagination li')[2]).toggleClass('active');
			break;
		default:
			$('.pagination li').each(function(i){
				$(this).toggleClass('active')
			});
			console.log('legal-text-container click handler didnt recognize text');
	}
}

$(document).ready(function() {
	switch (location.hash) {
		case '#terms':
			break;
		case '#eula':
			state = 'EULA';
			break;
		case '#privacy':
			state = 'Privacy Policy';
			break;
		default:
			state = 'EULA';
	}
	setLegalContainerText();
});

$('li').on('click', function(e){
	//toggle of active button
	switch (state) {
		case 'EULA':
			$($('.pagination li')[0]).toggleClass('active');
			break;
		case 'Privacy Policy':
			$($('.pagination li')[1]).toggleClass('active');
			break;
		case 'Terms of Use':
			$($('.pagination li')[2]).toggleClass('active');
			break;
	}
	state = $(e.target).text();
	setLegalContainerText();
})