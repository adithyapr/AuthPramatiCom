	$(function() {
		var d = new Date();

		$( "#doj" ).datepicker({ dateFormat: 'dd/mm/yy' });
		$( "#dob" ).datepicker({ dateFormat: 'dd/mm/yy', changeYear: true, yearRange: '1920:'+d.getFullYear() });


		//var bu_mapping = jQuery.parseJSON('{"imaginea":"imaginea", "pramati":"pramati", "middleware":"middleware", "qontext":"qontext", "socialtwist": "socialtwist", "gna":"imaginea", "corp":"pramati", "appserver":"imaginea"}');
		var bu_mapping = jQuery.parseJSON('{"imaginea":"imaginea", "pramati":"pramati", "middleware":"middleware", "qontext":"qontext", "socialtwist": "socialtwist"}');

		// Email Options triggering events
		$("#fname").on('change', {bypass: 'name'}, showEmailOptions);
		$('#lname').on('change',  {bypass: 'name'}, showEmailOptions);
		$('#bu').on('change', {bypass: 'bu'}, showEmailOptions);
		$('#oemail').on('focus', {bypass: 'email'}, showEmailOptions);

		function showEmailOptions(eventObj) {
			var oemail = $('#oemail').val();
			var bypass = eventObj.data.bypass;
			if (bypass=='email' || jQuery.trim(oemail) != '') {
				if (bypass != 'bu') {
					var fname = $('#fname').val().toLowerCase();
					var lname = $('#lname').val().toLowerCase();
					if (isValidInput(fname, 'name') && isValidInput(lname, 'name')) {
						var emailOptions = [];
						var initial = lname.substr(0,1);
						var fnames = fname.split(' ');
						if (fnames.length > 1) {
							emailOptions.push(jQuery.trim(fnames[0])+'.'+initial);
							emailOptions.push(jQuery.trim(fnames[1])+'.'+initial);
							emailOptions.push(jQuery.trim(fnames[0])+'.'+fnames[1].substr(0,1));
						} else {
							emailOptions.push(fname+'.'+initial);
						}
						var emailOptionsHTML = "<ul>";
						for(var i=0; i<emailOptions.length; i++) {
							emailOptionsHTML += "<li><input type='radio' name='emailopt' value='"+emailOptions[i]+"'>"+emailOptions[i]+"</li>";
						}
						emailOptionsHTML += "<li></ul>";
						$('#tdOfficialEmail').html(emailOptionsHTML);
						$('input:radio[name=emailopt]').on('click', emailSelected);		
						if (bypass == 'name') {
							$('#oemail').val('');
							$('#chkoemailflag').html('');
							$('#uid').val('');
							$('#chkuidflag').html('');
						} 
					} else {
						$('#fnameflag').html('');
						$('#lnameflag').html('');
						if (!isValidInput(fname, 'name')){
							$('#fnameflag').html("<img src='/css/images/cancel.png'> Not valid name");
							$('#fname').focus();
						} else if (!isValidInput(lname, 'name')) {
							$('#lnameflag').html("<img src='/css/images/cancel.png'> Not valid name");
							$('#lname').focus();
						}		
					}
				} else {
					$('input[name=oemail]').val($('input:radio[name=emailopt]:checked').val()+"@"+bu_mapping[$("select[name='bu'] option:selected").val()]+".com");
					checkEmailAvailability();
				}	
			}
		}


		function isValidInput(str, type) {
			if (type=='name' && /^[\.a-zA-Z\s]+$/.test(jQuery.trim(str))) {
				return true;
			} else if (type=='email' && /^[a-zA-Z0-9\._-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,4}$/.test(jQuery.trim(str))) {
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
			} else if (type=='designation' && /^[()\s.,a-zA-Z0-9_-]+$/.test(jQuery.trim(str))) {
				return true;
			} else {
				return false;
			}
		}

		function emailSelected() {
			$('input[name=oemail]').val($('input:radio[name=emailopt]:checked').val()+"@"+bu_mapping[$("select[name='bu'] option:selected").val()]+".com");
			$('#chkoemail').on('click', checkEmailAvailability);
			checkEmailAvailability();
		}
		function checkEmailAvailability() {
			var oemail = $('#oemail').val();
			$('#fnameflag').html('');
			$('#lnameflag').html('');
			$('#oemailflag').html('');
			$('#chkoemailflag').html('');
			if (isValidInput(oemail, 'oemail')) {
				
				// Do Ajax Call - To check the availability
				$.ajax({
					type: 'POST',
					url: '/ajax_handler.pl?t='+d.getTime(),
					cache: false,
					timeout: 15000,
					data: {"type": "email", "email": oemail},
					success: function(result) {
						if (result == '0') {
							$('#chkoemailflag').html("<img src='/css/images/accept.png' alt='Available'> Available");
							var uid = oemail.substr(0, oemail.indexOf('@'));
							$('#uid').val(uid.replace(".",""));
							initMailAccount();
							checkUidAvailability();
						} else if (result == '1') {
							$('#chkoemailflag').html("<img src='/css/images/cancel.png' alt='UnAvailable'> Unavailable");
						} else {
							$('#chkoemailflag').html("<img src='/css/images/cancel.png' alt='UnAvailable'> Error");
						}
					},
					error: function(objRequest, errortype) {
					    	if (errortype == 'timeout') {
					      		$('#chkoemailflag').html("<img src='/css/images/cancel.png' alt='Error'> Error");
					    	}
					}

				});	
			} else {
				$('#oemailflag').html("<img src='/css/images/cancel.png'> Not valid email");
				$('#oemail').focus();
			}
		}

		$('#chkuid').on('click', checkUidAvailability);
		
		function initMailAccount() {
			var domain = bu_mapping[$("select[name='bu'] option:selected").val()];
			$('#optMailbox').html("");			
			if (domain == "imaginea" || domain == "pramati") {
				$("#chkmailbox").attr('checked', 'checked');
				$("#chkmailbox").attr('disabled', 'disabled');
			} else {
				$("#chkmailbox").attr('checked', false);
				$("#chkmailbox").attr('disabled', false);
				var mailAccOpt = "<input type='radio' name='optMailAcc' value='imaginea' checked='checked'> Imaginea &nbsp; <input type='radio' name='optMailAcc' value='pramati'> Pramati";
				$('#optMailbox').html(mailAccOpt);
			}
		}
		
		function checkUidAvailability() {
			$('#uidflag').html('');
			$('#chkuidflag').html('');
			var uid = $('#uid').val();
			if (isValidInput(uid, 'uid')) {
				// Do Ajax Call - To check the availability
				$.ajax({
					type: 'POST',
					url: '/ajax_handler.pl?t='+d.getTime(),
					cache: false,
					timeout: 15000,
					data: {"type": "uid", "uid": uid},
					success: function(result) {
						if (result == '0') {
							$('#chkuidflag').html("<img src='/css/images/accept.png' alt='Available'> Available");
						} else if (result == '1') {
							$('#chkuidflag').html("<img src='/css/images/cancel.png' alt='UnAvailable'> Unavailable");
						}
					},
					error: function(objRequest, errortype) {
					    	if (errortype == 'timeout') {
					      		$('#chkuidflag').html("<img src='/css/images/cancel.png' alt='Error'> LDAP Error");
					    	}
					}
				});	
			} else {
				$('#uidflag').html("<img src='/css/images/cancel.png'> Not valid UserID");
				$('#uid').focus();
			}
		}
		
		$('#addUserFrm').submit(
			function() {
				var frmErrors = false;
				// FirstName
				var fname = $('#fname').val();
				if (jQuery.trim(fname) == "") {
					$('#fnameflag').html("<img src='/css/images/cancel.png'> Cannot be empty");
					frmErrors = true;
				} else if (!isValidInput(fname, 'name')) {
					$('#fnameflag').html("<img src='/css/images/cancel.png'> Only alphabets");
					frmErrors = true;
				} else {
					$('#fnameflag').html("");
				}

				// LastName
				var lname = $('#lname').val();
				if (jQuery.trim(lname) == "") {
					$('#lnameflag').html("<img src='/css/images/cancel.png'> Cannot be empty");
					frmErrors = true;
				} else if (!isValidInput(lname, 'name')) {
					$('#lnameflag').html("<img src='/css/images/cancel.png'> Only alphabets");
					frmErrors = true;
				} else {
					$('#lnameflag').html("");
				}

				// Personal Email 
				var pemail = $('#pemail').val();
				if (jQuery.trim(pemail) == "") {
					$('#pemailflag').html("<img src='/css/images/cancel.png'> Cannot be empty");
					frmErrors = true;
				} else if (!isValidInput(pemail, 'email')) {
					$('#pemailflag').html("<img src='/css/images/cancel.png'> Not valid email");
					frmErrors = true;
				} else {
					$('#pemailflag').html("");
				}

				// Mobile 
				var pmobile = $('#pmobile').val();
				if (jQuery.trim(pmobile) == "") {
					$('#pmobileflag').html("<img src='/css/images/cancel.png'> Cannot be empty");
					frmErrors = true;
				} else if (!isValidInput(pmobile, 'mobile')) {
					$('#pmobileflag').html("<img src='/css/images/cancel.png'> Not valid mobile");
					frmErrors = true;
				} else {
					$('#pmobileflag').html("");
				}

				// Date of birth 
				var dob = $('#dob').val();
				if (jQuery.trim(dob) == "") {
					$('#dobflag').html("<img src='/css/images/cancel.png'> Cannot be empty");
					frmErrors = true;
				} else if (!isValidInput(dob, 'date')) {
					$('#dobflag').html("<img src='/css/images/cancel.png'> Not valid date");
					frmErrors = true;
				} else {
					$('#dobflag').html("");
				}

				// Date of joining 
				var doj = $('#doj').val();
				if (jQuery.trim(doj) == "") {
					$('#dojflag').html("<img src='/css/images/cancel.png'> Cannot be empty");
					frmErrors = true;
				} else if (!isValidInput(doj, 'date')) {
					$('#dojflag').html("<img src='/css/images/cancel.png'> Not valid date");
					frmErrors = true;
				} else {
					$('#dojflag').html("");
				}

				// Job Title
				var designation = $('#designation').val();
				if (jQuery.trim(designation) == "") {
					$('#designationflag').html("<img src='/css/images/cancel.png'> Cannot be empty");
					frmErrors = true;
				} else if (!isValidInput(designation, 'designation')) {
					$('#designationflag').html("<img src='/css/images/cancel.png'> Not valid designation");
					frmErrors = true;
				} else {
					$('#designationflag').html("");
				}


				// Official Email 
				var oemail = $('#oemail').val();
				if (jQuery.trim(oemail) == "") {
					$('#oemailflag').html("<img src='/css/images/cancel.png'> Cannot be empty");
					frmErrors = true;
				} else if (!isValidInput(oemail, 'email')) {
					$('#oemailflag').html("<img src='/css/images/cancel.png'> Not valid email");
					frmErrors = true;
				} else {
					$('#oemailflag').html("");
				}

				// User ID 
				var uid = $('#uid').val();
				if (jQuery.trim(uid) == "") {
					$('#uidflag').html("<img src='/css/images/cancel.png'> Cannot be empty");
					frmErrors = true;
				} else if (!isValidInput(uid, 'uid')) {
					$('#uidflag').html("<img src='/css/images/cancel.png'> Not valid UserID");
					frmErrors = true;
				} else {
					$('#uidflag').html("");
				}

				// Employee ID
				var empid = $('#empid').val();
				if (jQuery.trim(empid) == "") {
					$('#empidflag').html("<img src='/css/images/cancel.png'> Cannot be empty");
					frmErrors = true;
				} else if (!isValidInput(empid, 'empid')) {
					$('#empidflag').html("<img src='/css/images/cancel.png'> Not valid Employee Number");
					frmErrors = true;
				} else {
					$('#empidflag').html("");
				}
								
				if (frmErrors) {
					return false;
				} else {
					return true;
				}
				
			}
		);
		
	});
