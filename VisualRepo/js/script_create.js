$(function() {
	$('#conUserFrm').submit(
		function(){
			var d = new Date();
			var data = $(this).serialize();
			$('.tbdisplay').html("<tr><td align='center'><img src='/css/images/spinner.gif'></td></tr>");
			$.ajax({
				type: 'POST',
				url: '/ajax_handler.pl?t='+d.getTime(),
				cache: false,
				timeout: 15000,
				data: data,
				success: function(result) {
						if (result == 'success') {
							$('.tbdisplay').html("<tr><th colspan='2'> New profile creation initiated, user will be notified shortly </th></tr><tr><td colspan='2'>&nbsp;</td></tr><tr><td colspan='2'>Click <a href='adduser.pl' class='linktxt'>here</a> to create new account.</td></tr>");
						} else if (result == 'error') {
							$('.tbdisplay').html("<tr><td colspan='2'>Error! Please contact IT team for assistance.</td></tr>");
						}
					},
				error: function(objRequest, errortype) {
				    	if (errortype == 'timeout') {
				      		$('.tbdisplay').html("<tr><td colspan='2'>Error! Please contact IT team for assistance.</td></tr>");
				    	}
				}
			});	
			return false;
		}
	);
});
