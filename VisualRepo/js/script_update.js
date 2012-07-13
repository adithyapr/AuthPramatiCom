$(function() {
	var d = new Date();

	$( "#birthdate" ).datepicker({ dateFormat: 'dd/mm/yy', changeYear: true, yearRange: '1920:'+d.getFullYear() });

	function isValidInput(str, type) {
		if (type=='name' && /^[\.a-zA-Z\s]+$/.test(jQuery.trim(str))) {
			return true;
		} else if (type=='email' && /^[a-zA-Z0-9._-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,4}$/.test(jQuery.trim(str))) {
			return true;
		} else if (type=='oemail' && /^[a-z]+\.[a-z]+@[a-z]+\.[a-z]{3}/.test(jQuery.trim(str))) {
			return true;
		} else if (type=='mobile' && /^(\+91|0)?[0-9]{10}$/.test(jQuery.trim(str))) {
			return true;
		} else if (type=='uid' && /^[a-z]+$/.test(jQuery.trim(str))) {
			return true;
		} else if (type=='date' && /^[0-9]{2}\/[0-9]{2}\/[0-9]{4}$/.test(jQuery.trim(str))) {
			return true;
		} else if (type=='empid' && /^[0-9]+$/.test(jQuery.trim(str))) {
			return true;
		} else if (type=='addr' && /^[()\s.,\na-zA-Z0-9/_:#-]+$/.test(jQuery.trim(str))) {
			return true;
		} else if (type=='designation' && /^[()\s.,a-zA-Z0-9_-]+$/.test(jQuery.trim(str))) {
			return true;
		} else {
			return false;
		}
	}

	$('#copyAddress').click(
		function() {
			var chkFlag = this.checked;
			if (chkFlag) {
				var tempAddr = $('#postalAddress').val();
				if (jQuery.trim(tempAddr) != "") {
					$('#homePostalAddress').val(tempAddr);
				} else {
					alert("No address details to copy");
				}
			} else {
				$('#homePostalAddress').val("");
			}
		}
	);

	$('#updUserFrm').submit(
		function() {
			var noErrors = true;
			// Personal Email 
			var alternatemail = $('#alternatemail').val();
			if (jQuery.trim(alternatemail) == "") {
				$('#alternatemailflag').html("<img src='/css/images/cancel.png'> Cannot be empty");
				noErrors = false;
			} else if (!isValidInput(alternatemail, 'email')) {
				$('#alternatemailflag').html("<img src='/css/images/cancel.png'> Not valid email");
				noErrors = false;
			} else {
				$('#alternatemailflag').html("");
			}
			// Mobile 
			var mobile = $('#mobile').val();
			if (jQuery.trim(mobile) == "") {
				$('#mobileflag').html("<img src='/css/images/cancel.png'> Cannot be empty");
				noErrors = false;
			} else if (!isValidInput(mobile, 'mobile')) {
				$('#mobileflag').html("<img src='/css/images/cancel.png'> Not valid mobile");
				noErrors = false;
			} else {
				$('#mobileflag').html("");
			}

			// Date of birth 
			var birthdate = $('#birthdate').val();
			if (jQuery.trim(birthdate) == "") {
				$('#birthdateflag').html("<img src='/css/images/cancel.png'> Cannot be empty");
				noErrors = false;
			} else if (!isValidInput(birthdate, 'date')) {
				$('#birthdateflag').html("<img src='/css/images/cancel.png'> Not valid date");
				noErrors = false;
			} else {
				$('#birthdateflag').html("");
			}

			// Department
			var department = $('#department').val();
			if (jQuery.trim(department) == "") {
				$('#departmentflag').html("<img src='/css/images/cancel.png'> Cannot be empty");
				noErrors = false;
			} else if (!isValidInput(department, 'name')) {
				$('#departmentflag').html("<img src='/css/images/cancel.png'> Not valid department");
				noErrors = false;
			} else {
				$('#departmentflag').html("");
			}


			// Temporary Address
			var postalAddress = $('#postalAddress').val();
			if (jQuery.trim(postalAddress) == "") {
				$('#postalAddressflag').html("<img src='/css/images/cancel.png'> Cannot be empty");
				noErrors = false;
			} else if (!isValidInput(postalAddress, 'addr')) {
				$('#postalAddressflag').html("<img src='/css/images/cancel.png'> Not valid address");
				noErrors = false;
			} else {
				$('#postalAddressflag').html("");
			}

			// Permanent Address
			var homePostalAddress = $('#homePostalAddress').val();
			if (jQuery.trim(homePostalAddress) == "") {
				$('#homePostalAddressflag').html("<img src='/css/images/cancel.png'> Cannot be empty");
				noErrors = false;
			} else if (!isValidInput(homePostalAddress, 'addr')) {
				$('#homePostalAddressflag').html("<img src='/css/images/cancel.png'> Not valid address");
				noErrors = false;
			} else {
				$('#homePostalAddressflag').html("");
			}

			// Job Title
			var designation = $('#title').val();
			if (jQuery.trim(designation) == "") {
				$('#titleflag').html("<img src='/css/images/cancel.png'> Cannot be empty");
				noErrors = false;
			} else if (!isValidInput(designation, 'designation')) {
				$('#titleflag').html("<img src='/css/images/cancel.png'> Not valid designation");
				noErrors = false;
			} else {
				$('#titleflag').html("");
			}

			// Location
			var location = $('#location').val();
			if (location == "") {
				$('#locationflag').html("<img src='/css/images/cancel.png'> Cannot be empty");
				noErrors = false;
			} else {
				$('#locationflag').html("");
			}		
			
			if (noErrors) {
				submitUpdFrm();
			}
			return false; 
		}
	);

	function submitUpdFrm() {
		// Do Ajax Call - To check the availability
		var data = $('#updUserFrm').serialize();
		console.log(data);
		$.ajax({
			type: 'POST',
			url: '/ajax_handler.pl?t='+d.getTime(),
			cache: false,
			timeout: 15000,
			data: data,
			success: function(result) {
				if (result == 'success') {
					$('.tbdisplay').html("<tr><th colspan='3'> Process initiated, you will be notified shortly. <div id='upd_time'> Profile would be updated in the next 20 sec .... </div></th></tr></tr>");
					setTimeout(function() { startRedirectionCounter(1); }, 1000);
				} else if (result == 'error') {
					$('.tbdisplay').html("<tr><td colspan='3'>Error! Please contact IT team for assistance.</td></tr>");
				}
			},
			error: function(objRequest, errortype) {
			    	if (errortype == 'timeout') {
			      		$('.tbdisplay').html("<tr><td colspan='3'>Error! Please contact IT team for assistance.</td></tr>");
			    	}
			}
		});
	}

	function startRedirectionCounter(i) {
		$('#upd_time').html(" Profile would be updated in the next "+(20-i)+" sec .... ");
		i++;
		if (i==20) {
			location.reload(true);
		} else {
			setTimeout(function() { startRedirectionCounter(i); }, 1000);
		}
	}
});
