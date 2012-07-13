#!/usr/bin/perl

package UsrMgmTl::PTemplate;
my %lconfig = &UsrMgmTl::Init::readConfig();

sub menuTemplate {
	my ($active_tab, $canViewEventsTab) = @_;
	my $add_li='', $delete_li='', $events_li='', $update_li='';	
	my $logout = $lconfig{link_logout};
	my $main_portal = $lconfig{link_main};
	
	if ($active_tab eq 'add') {
		$add_li = 'ui-tabs-selected ui-state-active';
	} elsif ($active_tab eq 'delete') {
		$delete_li = 'ui-tabs-selected ui-state-active';
	} elsif ($active_tab eq 'update') {
		$update_li = 'ui-tabs-selected ui-state-active';
	}
	my $username = $ENV{REMOTE_USER};
	my $tabs = <<MENUTEMPLATE;
<ul class="ui-tabs-nav ui-helper-reset ui-helper-clearfix ui-widget-header ui-corner-all">
<li class="ui-state-default ui-corner-top $update_li">
	<a href="/update/"><span>
		<img width="16" height="16" alt="Update User Details" src="/css/images/vcard_edit.png">Update User</span>
	</a>
</li>
<li class="ui-state-default ui-corner-top $add_li">
	<a href="/add/"><span>
		<img width="16" height="16" alt="password" src="/css/images/user_suit.png">Add User</span>
	</a>
</li>
<li class="ui-state-default ui-corner-top $delete_li">
	<a href="/delete/"><span>
		<img width="16" height="16" alt="password" src="/css/images/search.png">Delete/Reset</span>
	</a>
</li>
<li class="ui-state-default ui-corner-top">
	<a href="$main_portal"><span>
		<img width="16" height="16" alt="logout" src="/css/images/bullet_go.png">Main Portal</span>
	</a>
</li>
<li class="ui-state-default ui-corner-top">
	<a href="$logout"><span>
		<img width="16" height="16" alt="logout" src="/css/images/door_out.png">Logout</span>
	</a>
</li>
MENUTEMPLATE

	if ($canViewEventsTab) {	
		if ($active_tab eq 'events') {
			$events_li = 'ui-tabs-selected ui-state-active';
		}
		$tabs = $tabs."<li class='ui-state-default ui-corner-top $events_li'><a href='/eventslog/'><span><img width='16' height='16' alt='Events Log' src='/css/images/key.png'>Events Log</span></a></li>";
	}
	my $tmpl = $tabs."<li><span class='user'>Connected as $username</span></li></ul>";

	return $tmpl;
}

sub addUserConfirmTemplate {
	my ($uid,$pemail,$dob,$bu,$fname,$lname,$doj,$empid,$oemail,$pmobile,$location,$designation, $mailBoxAcc,$canViewEventsTab) = @_;
	
	my %bunits = UsrMgmTl::PLDAP::getBUs();
	my $bunit = $bunits{$bu}; 
	my $homeDirectory = " ";
	my $folder = substr($oemail, 0, index($oemail, '@'));	
	if ($mailBoxAcc ne '') {
		$homeDirectory = "/home/${mailBoxAcc}.com/$folder"
	}
	my $menu = &menuTemplate('add',$canViewEventsTab);

	my $tmpl = <<ADDCONFIRMTMPL;
	<div id='page'>
		<div class='message'> Add User </div>
		$menu
		<form id='conUserFrm' name='conUserFrm' method='POST' action=''>
			<table class='tbdisplay'>
				<tr>
					<th>dn</th>
					<td><input type='text' name='dn' id='dn' value="uid=$uid,ou=Employees,dc=pramati,dc=com" readonly></td>
				</tr>
				<tr>
					<th>alternatemail</th>
					<td><input type='text' name='alternatemail' id='alternatemail' value="$pemail" readonly></td>
				</tr>
				<tr>
					<th>birthdate</th>
					<td><input type='text' name='birthdate' id='birthdate' value="$dob" readonly></td>
				</tr>
				<tr>
					<th>businessunit</th>
					<td><input type='text' name='businessunit' id='businessunit' value="$bunit"></td>
				</tr>
				<tr>
					<th>title</th>
					<td><input type='text' name='title' id='title' value="$designation"></td>
				</tr>
				<tr>
					<th>cn</th>
					<td><input type='text' name='cn' id='cn' value="$fname $lname" readonly></td>
				</tr>
				<tr>
					<th>department</th>
					<td><input type='text' name='department' id='department' value="Engineering"></td>
				</tr>
				<tr>
					<th>employeenumber</th>
					<td><input type='text' name='employeenumber' id='employeenumber' value="$empid" readonly></td>
				</tr>
				<tr>
					<th>firstname</th>
					<td><input type='text' name='firstname' id='firstname' value="$fname" readonly></td>
				</tr>	
				<tr>
					<th>gecos</th>
					<td><input type='text' name='gecos' id='gecos' value="$fname $lname" readonly></td>
				</tr>	
				<tr>
					<th>gidnumber</th>
					<td><input type='text' name='gidnumber' id='gidnumber' value="$empid"></td>
				</tr>	
				<tr>
					<th>homedirectory</th>
					<td><input type='text' name='homedirectory' id='homedirectory' value="$homeDirectory"></td>
				</tr>	
				<tr>
					<th>joiningdate</th>
					<td><input type='text' name='joiningdate' id='joiningdate' value="$doj" readonly></td>
				</tr>
				<tr>
					<th>releavingDate</th>
					<td><input type='text' name='releavingDate' id='releavingDate' value="00/00/0000" readonly></td>
				</tr>		
				<tr>
					<th>lastname</th>
					<td><input type='text' name='lastname' id='lastname' value="$lname" readonly></td>
				</tr>	
				<tr>
					<th>location</th>
					<td><input type='text' name='location' id='location' value="$location" readonly></td>
				</tr>
				<tr>
					<th>homePostalAddress</th>
					<td><input type='text' name='homePostalAddress' id='homePostalAddress' value=""></td>
				</tr>	
				<tr>
					<th>postalAddress</th>
					<td><input type='text' name='postalAddress' id='postalAddress' value=""></td>
				</tr>
				<tr>
					<th>loginshell</th>
					<td><input type='text' name='loginshell' id='loginshell' value="/bin/bash"></td>
				</tr>	
				<tr>
					<th>mail</th>
					<td><input type='text' name='mail' id='mail' value="$oemail" readonly></td>
				</tr>	
				<tr>
					<th>mobile</th>
					<td><input type='text' name='mobile' id='mobile' value="$pmobile" readonly></td>
				</tr>	
				<tr>
					<th>objectclass</th>
					<td>posixAccount</td>
				</tr>	
				<tr>
					<th>objectclass</th>
					<td>top</td>
				</tr>	
				<tr>
					<th>objectclass</th>
					<td>inetOrgPerson</td>
				</tr>	
				<tr>
					<th>objectclass</th>
					<td>PramatiEmployeeCustom</td>
				</tr>	
				<tr>
					<th>objectclass</th>
					<td>organizationalPerson</td>
				</tr>	
				<tr>
					<th>objectclass</th>
					<td>person</td>
				</tr>	
				<tr>
					<th>personstatus</th>
					<td><input type='text' name='personstatus' id='personstatus' value="1" readonly></td>
				</tr>	
				<tr>
					<th>sn</th>
					<td><input type='text' name='sn' id='sn' value="$fname $lname" readonly></td>
				</tr>	
				<tr>
					<th>uid</th>
					<td><input type='text' name='uid' id='uid' value="$uid" readonly></td>
				</tr>	
				<tr>
					<th>uidnumber</th>
					<td><input type='text' name='uidnumber' id='uidnumber' value="$empid"></td>
				</tr>	
				<tr>
					<th>userpassword</th>
					<td><input type='text' name='userpassword' id='userpassword' value="pramati123"></td>
				</tr>	
				<tr>
					<td colspan='2'>
						<div class='buttons'>
							<input type='hidden' name='type' id='type' value="$lconfig{CREATE}">
							<input type='hidden' name='mailboxAcc' id='mailboxAcc' value="$mailBoxAcc">
							<button class='negative' type='reset' onclick="window.history.back()"><img alt='' src='/css/images/cancel.png'>Cancel</button>
							<button class='positive' type='submit'><img alt='' src='/css/images/accept.png'>Submit</button>
						</div>
					</td>
				</tr>
			</table>
		</form>
	</div>
ADDCONFIRMTMPL

	return $tmpl;
}

sub addUserTemplate {
	my ($canViewEventsTab) = @_;
	my $menu = &menuTemplate('add',$canViewEventsTab);
	
	my %bu = UsrMgmTl::PLDAP::getBUs;
	my $buTmpl = '';	
	while (my($k,$v) = each(%bu)) {
		$buTmpl .= "<option value='$k'>$v</option>";
	}

	my %loc = UsrMgmTl::PLDAP::getLocations;
	my $locTmpl = '';	
	while (my($k,$v) = each(%loc)) {
		$locTmpl .= "<option value='$k'>$v</option>";
	}

			
	my $tmpl = <<ADDTMPL;
	<div id='page'>
		<div class='message'> Add User </div>
		$menu
		<form id='addUserFrm' name='addUserFrm' method='POST' action=''>
			<table class='tbdisplay'>
				<tr>
					<td colspan='3'><span class='table_section'> Personal </span></td>
				</tr>
				<tr>
					<th> First Name </th>
					<td><input type='text' name='fname' id='fname'></td>
					<td id='fnameflag'></td>
				</tr>
				<tr>
					<th> Last Name </th>
					<td><input type='text' name='lname' id='lname'></td>
					<td id='lnameflag'></td>
				</tr>
				<tr>
					<th> Personal Email </th>
					<td><input type='text' name='pemail' id='pemail'></td>
					<td id='pemailflag'></td>
				</tr>
				<tr>
					<th> Mobile </th>
					<td><input type='text' name='pmobile' id='pmobile'></td>
					<td id='pmobileflag'></td>
				</tr>
				<tr>
					<th> Date of Birth </th>
					<td><input type='text' name='dob' id='dob'></td>
					<td id='dobflag'></td>
				</tr>
				<tr>
					<td colspan='3' align='center'><span class='table_section'> Official </span></td>
				</tr>
				<tr>
					<th> Date of Joining</th>
					<td><input type='text' name='doj' id='doj'></td>
					<td id='dojflag'></td>
				</tr>
				<tr>
					<th> Job Title</th>
					<td><input type='text' name='designation' id='designation'></td>
					<td id='designationflag'></td>
				</tr>
				<tr>
					<th> Location </th>
					<td><select name='location' id='location'>$locTmpl</select></td>
					<td>&nbsp;</td>
				</tr>
				<tr>
					<th> Business Unit </th>
					<td align='left'><select id='bu' name='bu'>$buTmpl</select></td>
					<td>&nbsp;</td>
				</tr>
				<tr>
					<th> EMail </th>
					<td>
						<div id='tdOfficialEmail'></div>
						<input type='text' name='oemail' id='oemail'>
					</td>
					<td id='oemailflag'></td>
				</tr>
				<tr>
					<th>&nbsp;</th>
					<td><span id='chkoemail' class='linktxt'> check availability </span></td>
					<td id='chkoemailflag'></td>
				</tr>
				<tr>
					<th>&nbsp;</th>
					<td>
						<input type='checkbox' name='chkmailbox' id='chkmailbox' value='1'> Create mail account 
						<div id='optMailbox'></div>
					</td>
					<td id='chkmailboxflag'></td>
				</tr>
				<tr>
					<th> UserID </th>
					<td><input type='text' name='uid' id='uid'></td>
					<td id='uidflag'></td>
				</tr>
				<tr>
					<th>&nbsp;</th>
					<td><span id='chkuid' class='linktxt'> check availability </span></td>
					<td id='chkuidflag'></td>
				</tr>
				<tr>
					<th> Employee Number </th>
					<td><input type='text' name='empid' id='empid'></td>
					<td id='empidflag'></td>
				</tr>
				<tr>
					<td colspan='3'>
						<div class='buttons'>
							<button class='positive' type='submit'><img alt='' src='/css/images/accept.png'>Submit</button>
						</div>
					</td>
				</tr>
			</table>
		</form>
	</div>
ADDTMPL

	return $tmpl;
}

sub searchUserTemplate {
	my ($canViewEventsTab) = @_;
	my $menu = &menuTemplate('delete',$canViewEventsTab);

	my $tmpl = <<DELTMPL;
	<div id='page'>
		<div class='message'> Delete/Reset User </div>
		$menu
		<form id='searchLdapFrm' name='searchLdapFrm' method='POST' action=''>
			<table>
				<tr>
					<th> Search </th>
					<td><input type='text' name='txtSearch' id='txtSearch'></td>
					<td>
						<div class='buttons'>
							<button class='positive' type='submit'><img alt='' src='/css/images/accept.png'>Submit</button>
						</div>
					</td>
				</tr>		
				<tr>
					<td>&nbsp;</td>
					<td colspan='2' align='left'>
						<input type='radio' name='searchType' value='uid' checked> UserID &nbsp;
						<input type='radio' name='searchType' value='email'> Email &nbsp;
						<input type='radio' name='searchType' value='name'> Name
					</td>
				</tr>
			</table>
		</form>
		<form id='deleteLdapFrm' name='deleteLdapFrm' method='POST' action='' style="display:none">		
			<table id='ldapDataRes' ></table>
			<table id='ldapDataResSub'></table>
		</form>
	</div>
DELTMPL

	return $tmpl;
}

sub eventsLogTemplate {
	my ($canViewEventsTab) = @_;
	my $menu = &menuTemplate('events', $canViewEventsTab);

	my $tmpl = <<EVTTMPL;
	<div id='page'>
		<div class='message'> Events Log </div>
		$menu
EVTTMPL
	my $res = UsrMgmTl::PDBI::get_events_log();
	$tmpl = $tmpl."<form><table id='ldapDataRes' ><tr><th>ID</th><th>Category</th><th>Operation</th><th>Status</th><th>Attempts</th><th>InvokedBy</th><th>InvokedAt</th><th>LastAttemptAt</th></tr>$res</table></div></form>";
	return $tmpl;		
}

sub updateDetailsTemplate {
	my ($canViewEventsTab) = @_;
	my $menu = &menuTemplate('update',$canViewEventsTab);
	my %details = UsrMgmTl::PLDAP::getDetailsByUid($ENV{REMOTE_USER});
	my $formTmpl = "<h3> No user details found </h3>";

	if (defined($details{dn})) {

		# Location dropdown list
		my %loc = UsrMgmTl::PLDAP::getLocations;
		my $locTmpl = '';	
		while (my($k,$v) = each(%loc)) {
			if ($k eq $details{location}) {
				$locTmpl .= "<option value='$k' selected>$v</option>";
			} else {
				$locTmpl .= "<option value='$k'>$v</option>";
			}			
		}
		if (!defined($loc{$details{location}})) {
			$locTmpl .= "<option value='' selected></option>";
		}	

		$formTmpl = <<DETAILS;
		<form id='updUserFrm' name='updUserFrm' method='POST' action=''>
			<table class='tbdisplay'>
				<tr>
					<td colspan='3'><span class='table_section'> Personal </span></td>
				</tr>
				<tr>
					<th>First Name</th>
					<td class='displaytxt'>$details{firstName}</td>
					<td>&nbsp;</td>
				</tr>
				<tr>
					<th>Last Name</th>
					<td class='displaytxt'>$details{lastName}</td>
					<td>&nbsp;</td>
				</tr>	
				<tr>
					<th>Date of Birth</th>
					<td class='displaytxt'><input type='text' name='birthdate' id='birthdate' value="$details{birthDate}"></td>
					<td id='birthdateflag'></td>
				</tr>
				<tr>
					<th>Personal Email</th>
					<td class='displaytxt'><input type='text' name='alternatemail' id='alternatemail' value="$details{alternateMail}"></td>
					<td id='alternatemailflag'></td>
				</tr>
				<tr>
					<th>Mobile</th>
					<td class='displaytxt'><input type='text' name='mobile' id='mobile' value="$details{mobile}"></td>
					<td id='mobileflag'></td>
				</tr>
				<tr>
					<th>Temporary Address</th>
					<td class='displaytxt'><textarea name='postalAddress' id='postalAddress'>$details{postalAddress}</textarea></td>
					<td id='postalAddressflag'></td>
				</tr>
				<tr>
					<th>&nbsp;</th>
					<td class='displaytxt'><input type='checkbox' name='copyAddress' id='copyAddress' value='on'>Both are same</td>
					<td>&nbsp;</td>
				</tr>
				<tr>
					<th>Permanent Address</th>
					<td class='displaytxt'><textarea name='homePostalAddress' id='homePostalAddress'>$details{homePostalAddress}</textarea></td>
					<td id='homePostalAddressflag'></td>
				</tr>
				<tr>
					<td colspan='3'><span class='table_section'> Official </span></td>
				</tr>
				<tr>
					<th>Job Title</th>
					<td class='displaytxt'><input type='text' name='title' id='title' value="$details{title}"></td>
					<td id='titleflag'></td>
				</tr>
				<tr>
					<th>Date of Joining</th>
					<td class='displaytxt'>$details{joiningDate}</td>
					<td>&nbsp;</td>
				</tr>
				<tr>
					<th>Business Unit</th>
					<td class='displaytxt'>$details{businessUnit}</td>
					<td>&nbsp;</td>
				</tr>
				<tr>
					<th>Department</th>
					<td class='displaytxt'><input type='text' name='department' id='department' value="$details{department}"></td>
					<td id='departmentflag'></td>
				</tr>
				<tr>
					<th>Location</th>
					<td class='displaytxt'><select name='location' id='location'>$locTmpl</select></td>
					<td id='locationflag'></td>
				</tr>	
				<tr>
					<th>Official Email</th>
					<td class='displaytxt'>$details{mail}</td>
					<td>&nbsp;</td>
				</tr>
				<tr>
					<th>Employee Number</th>
					<td class='displaytxt'>$details{employeeNumber}</td>
					<td>&nbsp;</td>
				</tr>
				<tr>
					<td colspan='3'>
						<div class='buttons'>
							<input type='hidden' name='dn' id='dn' value="$details{dn}">
							<input type='hidden' name='uid' id='uid' value="$details{uid}">
							<input type='hidden' name='mail' id='mail' value="$details{mail}">
							<input type='hidden' name='type' id='type' value="$lconfig{UPDATE}">
							<button class='positive' type='submit'><img alt='' src='/css/images/accept.png'>Submit</button>
						</div>
					</td>
				</tr>	
			</table>
		</form>
DETAILS
	}

	my $tmpl = <<TMPL;
	<div id='page'>
		<div class='message'> Update details </div>
		$menu
		$formTmpl
	</div>
TMPL
	return $tmpl;
}

sub noAccessTemplate {
	my ($page,$canViewEventsTab) = @_;

	my $menu = &menuTemplate($page,$canViewEventsTab);
	my $tmpl = <<TMPL;
	<div id='page'>
		<div class='message'> No Access to view this Page </div>
		$menu
	</div>
TMPL
	return $tmpl;
}

1;
		
