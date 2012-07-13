$(function() {
	$('#searchLdapFrm').submit(
		function() {
			var search = jQuery.trim($('#txtSearch').val());
			var option = $('input:radio[name=searchType]:checked').val();
			if (search != '') {
				var d = new Date();
				$.ajax({
					type: 'POST',
					url: '/ajax_handler.pl?t='+d.getTime(),
					cache: false,
					timeout: 15000,
					data: {"type": "search", "search": search, "option": option},
					success: function(result) {
						var jsonObj = jQuery.parseJSON(result);
						$('#deleteLdapFrm').css('display','block');
						if (jsonObj.data.length>0) {
							var tableHTML = '<tr><th>Name</th><th>User ID</th><th>Email</th><th>Date of Joining</th><th>Location</th><th>Delete</th><th>Reset Pwd</th><th>Forgot Pwd</th></tr>';
							for (rowObj in jsonObj.data) {
								tableHTML += "<tr>";
								tableHTML += "<td>"+jsonObj.data[rowObj].cn+"</td>";
								tableHTML += "<td>"+jsonObj.data[rowObj].uid+"</td>";
								tableHTML += "<td>"+jsonObj.data[rowObj].email+"</td>";
								tableHTML += "<td>"+jsonObj.data[rowObj].joiningdate+"</td>";
								tableHTML += "<td>"+jsonObj.data[rowObj].location+"</td>";

								tableHTML += "<td><input type='checkbox' id='chkDelUser' name='chkDelUser' value='"+jsonObj.data[rowObj].dn+"'></td>";
								tableHTML += "<td><input type='checkbox' id='chkResetUser' name='chkResetUser' value='"+jsonObj.data[rowObj].dn+"'</td>";
								tableHTML += "<td><input type='checkbox' id='chkForgotUser' name='chkForgotUser' value='"+jsonObj.data[rowObj].dn+"'</td>";
								tableHTML += "</tr>";
							}
							$('#ldapDataRes').html(tableHTML);
							$('table#ldapDataRes tr:even').addClass('rowEven');
							$('#ldapDataResSub').html("<tr><td><div class='buttons'><button class='positive' type='submit'><img alt='' src='/css/images/accept.png'>Submit</button></div></td></tr>");
						} else {
							$('#ldapDataRes').html("<tr> <th> No matching records found </th></tr>");
							$('#ldapDataResSub').html('');
						}
					},
					error: function(objRequest, errortype) {
					    	if (errortype == 'timeout') {
					      		$('#ldapDataRes').html("<tr><td colspan='2'>Error! Please contact IT team for assistance.</td></tr>");
					    	}
					}	
				});
			}
			return false;
		}
	);
	$('#deleteLdapFrm').submit(
		function() {
			var delDn = [], resetDn = [], forgotDn = [];
			$('input:checkbox[name=chkDelUser]:checked').each(
				function(i) {
					delDn.push($(this).val());	
				}
			); 
			$('input:checkbox[name=chkResetUser]:checked').each(
				function(i) {
					resetDn.push($(this).val());	
				}
			);
			$('input:checkbox[name=chkForgotUser]:checked').each(
				function(i) {
					forgotDn.push($(this).val());	
				}
			);
			if (delDn.length>0 || resetDn.length>0 || forgotDn.length>0) {
				var flag = confirm("Are you sure, you want to continue");
				if (flag) {
					$('#ldapDataResSub').html('');
					$('#ldapDataRes').html("<tr><td align='center'><img src='/css/images/spinner.gif'></td></tr>");
					var d = new Date();
					$.ajax({
		        			type: 'POST',
						url: '/ajax_handler.pl?t='+d.getTime(),
						cache: false,
						timeout: 15000,
						data: {"type":"d3b31aaecef4737e63a2ec5718019831e490350a", "delDn":delDn.join(':'), "resetDn":resetDn.join(':'), "forgotDn":forgotDn.join(':')},
						success: function(result) {
							if (result == 'success') {
								$('#ldapDataRes').html("<tr><th colspan='2'> Profile(s) update initiated, user(s) will be notified shortly </th></tr>");
							} else if (result == 'error') {
								$('#ldapDataRes').html("<tr><td colspan='2'>Error! Please contact IT team for assistance.</td></tr>");
							}
						},
						error: function(objRequest, errortype) {
						    	if (errortype == 'timeout') {
						      		$('#ldapDataRes').html("<tr><td colspan='2'>Error! Please contact IT team for assistance.</td></tr>");
						    	}
						}
					});
				}
			}

			return false;
		}
	);
});
