#!/usr/bin/perl

package UsrMgmTl::PLDAP;

use Net::LDAP;
use JSON;
use LWP::Simple;

my %lconfig = &UsrMgmTl::Init::readConfig();

sub init {
	my $ldap = Net::LDAP->new($lconfig{ldap_host});
	eval { $ldap->bind($lconfig{ldap_dn}, password=>$lconfig{ldap_pwd}); };
	if ($@) {
		UsrMgmTl::PLog::plog("Failed to connect LDAP : $@", ('error', 'debug'));
		UsrMgmTl::PLog::plog("PLDAP::init: Host: ".$lconfig{ldap_host}.", DN: ".$lconfig{ldap_dn}, ('debug'));
	} else {
		UsrMgmTl::PLog::plog("Connected to LDAP", ('debug'));
	}

	return $ldap;
}	

sub authenticate {
	my ($page) = @_;
	UsrMgmTl::PLog::plog('PLDAP::authenticate: Start', ('debug'));

	my $ldap = &init();
	my $mesg,@groups;
	my $hasAccess = 0;
	my $uid = $ENV{REMOTE_USER};

	if ($page eq 'add') {
		@groups = split(/,/, $lconfig{add_access_group});
	} elsif ($page eq 'delete') {
		@groups = split(/,/, $lconfig{delete_access_group});
	} elsif ($page eq 'events') {
		@groups = split(/,/, $lconfig{events_access_group});
	}
	if ($ldap) {
		foreach my $group (@groups) {
			my $results = $ldap->search(filter=>"(cn=$group)", base=>"ou=groups,dc=pramati,dc=com");
			my @entries = $results->entries;
			foreach my $entry (@entries) {
				my @members = $entry->get_value('member');
				foreach my $member (@members) {
					my @comp = split(/,/, $member);
					my $mem = substr($comp[0], 4);
					if ($mem eq $uid) {
						$hasAccess = 1;
						last;
					}
				}
			}
			if ($hasAccess == 1) {
				last;
			}
		}
	}
	UsrMgmTl::PLog::plog("PLDAP::authenticate: HasAccess => $hasAccess", ('debug'));
	UsrMgmTl::PLog::plog('PLDAP::authenticate: End', ('debug'));
	$ldap->unbind;	
	return $hasAccess;		
}

sub search {
	my ($type, $keyword, $option) = @_;
	UsrMgmTl::PLog::plog('PLDAP::search: Start', ('debug'));
	UsrMgmTl::PLog::plog("PLDAP::search: Type:$type, Keyword:$keyword, Option:$option", ('debug'));
	my $ldap = &init();
	my $mesg, $res, @entries, $daysGap;

	if ($ldap) {
		if ($type eq 'uid' || $type eq 'email' ) {
			if ($type eq 'uid') { 
				$mesg = $ldap->search(filter=>"(uid=$keyword)", base=>$lconfig{ldap_basedn});
			} elsif ($type eq 'email') {
				$mesg = $ldap->search(filter=>"(mail=$keyword)", base=>$lconfig{ldap_basedn});
			}
			$res = $mesg->count;
			if ($res eq '0') {
				if ($type eq 'uid') { 
					$mesg = $ldap->search(filter=>"(uid=$keyword)", base=>"ou=ExEmployees,dc=pramati,dc=com");
				} elsif ($type eq 'email') {
					$mesg = $ldap->search(filter=>"(mail=$keyword)", base=>"ou=ExEmployees,dc=pramati,dc=com");
				}			
				$res = $mesg->count;
				if ($res eq '1') {
					@entries = $mesg->entries;
					$daysGap = UsrMgmTl::PLog::getDaysBetween($entries[0]->get_value('releavingDate'));				
					if ($daysGap > $lconfig{ldap_exppolicy}) {
						$res = 0;
					}
				}				
			}
		} elsif ($type eq 'search') {
			if ($option eq 'email') {
				$mesg = $ldap->search(filter=>"(&(personstatus=1)(mail=*$keyword*))", base=>$lconfig{ldap_basedn});
			} elsif ($option eq 'uid') {
				$mesg = $ldap->search(filter=>"(&(personstatus=1)(uid=*$keyword*))", base=>$lconfig{ldap_basedn});
			} elsif ($option eq 'name') {
				$mesg = $ldap->search(filter=>"(&(personstatus=1)(cn=*$keyword*))", base=>$lconfig{ldap_basedn});
			}
			my $count = $mesg->count;
			$res = '{"data":[]}';
			if ($count > 0) {
				@entries = $mesg->entries;
				my $jsonData = '{"data":[';
				foreach my $entry (@entries) {
					$jsonData .= '{"dn":"'. $entry->dn() .'","cn":"'. $entry->get_value('cn') .'","uid":"'. $entry->get_value('uid') .'","email":"'. $entry->get_value('mail') .'","joiningdate": "'. $entry->get_value('joiningdate') .'","location": "'. $entry->get_value('location') .'"},';
				}
				$res = substr($jsonData,0,-1) . ']}';
			 }
		}
	}
	UsrMgmTl::PLog::plog("PLDAP::search: Return:$res", ('debug'));
	UsrMgmTl::PLog::plog('PLDAP::search: End', ('debug'));
	$ldap->unbind;	
	return $res;
}

sub create {
	my ($dbh, $rowId, $attempts, $invokedBy, $invokedAt, $jsonData) = @_;
	UsrMgmTl::PLog::plog('PLDAP::create: Start', ('debug'));

	my %ldapData = %{from_json($jsonData)};
	my $ldap = &init();
	my $info, $subject, $desc, $to, $cc, $from, $res;
	my $userpassword = "{CRYPT}".crypt($ldapData{userpassword}, 'EO');
	my $result = $ldap->add($ldapData{dn},
                attr => [ 'alternatemail' => $ldapData{alternatemail}, 
			  'birthdate' => $ldapData{birthdate},
			  'businessunit' => $ldapData{businessunit},
			  'cn' => $ldapData{cn},
			  'department' => $ldapData{department},
			  'employeenumber' => $ldapData{employeenumber},
			  'firstname' => $ldapData{firstname},
			  'gecos' => $ldapData{gecos},
			  'gidnumber' => $ldapData{gidnumber},
			  'homedirectory' => $ldapData{homedirectory},
			  'joiningdate' => $ldapData{joiningdate},
			  'lastname' => $ldapData{lastname},
			  'location' => $ldapData{location},
			  'loginshell' => $ldapData{loginshell},
			  'mail' => $ldapData{mail},
			  'mobile' => $ldapData{mobile},
			  'personstatus' => $ldapData{personstatus},
			  'sn' => $ldapData{sn},
			  'uid' => $ldapData{uid},
			  'uidnumber' => $ldapData{uidnumber},
	   		  'userpassword' => $userpassword,
	   		  'title' => $ldapData{title},
	   		  'releavingDate' => $ldapData{releavingDate},
	   		  'homePostalAddress' => $ldapData{homePostalAddress},
	   		  'postalAddress' => $ldapData{postalAddress},
			  'pwdReset' => 'TRUE',
                          'objectclass' => [ 'posixAccount', 'top', 'inetOrgPerson', 'PramatiEmployeeCustom', 'organizationalPerson', 'person']
                        ]
           );
	if ($result->is_error) {
		UsrMgmTl::PLog::plog("Create: Error creating user with uid '".$ldapData{uid}."'. Error: ".$result->error, ('error','debug'));
		UsrMgmTl::PDBI::update_event($dbh, $rowId, 0, $result->error);		

		$info = "{UID:".$ldapData{uid}.", Email:".$ldapData{mail}."}";
		$to=$lconfig{NTFY_ERROR_TO};
		$cc=$lconfig{NTFY_ERROR_CC};
		$from=$lconfig{NTFY_ERROR_FROM};
		$subject = "Error - User Management Tool : LDAP (Create)";
		UsrMgmTl::PEmail::ErrorNotification($to, $cc, $from, $subject, $rowId, 'LDAP', 'Create', $invokedBy, $invokedAt, $attempts, $info, $result->error);
	} else {
		UsrMgmTl::PLog::plog("LDAP (Create): Created user with uid '".$ldapData{uid}."'", ('audit','debug'));
		UsrMgmTl::PDBI::update_event($dbh, $rowId, 1, '');		

		$info = "{UID:".$ldapData{uid}.", Email:".$ldapData{mail}."}";
		$to=$lconfig{NTFY_LDAP_OP_TO};
		$cc=$lconfig{NTFY_LDAP_OP_CC};
		$from=$lconfig{NTFY_LDAP_OP_FROM};
		$subject = "Event - User Management Tool : LDAP (Create)";
		$desc = "User Management Tool successfully executed create user (LDAP) request. Details";
		UsrMgmTl::PEmail::Notification($to, $cc, $from, $subject, $rowId, 'LDAP', 'Create', $invokedBy, $invokedAt, $attempts, $info, $desc);

		my $hr=$lconfig{NTFY_WELCOME_HR_NAME};
		$cc=$lconfig{NTFY_WELCOME_CC};
		$from=$lconfig{NTFY_WELCOME_FROM};
		$subject = "A Very Warm Welcome To Pramati!";
		UsrMgmTl::PEmail::welcomeNotification($ldapData{mail}, $cc, $from, $subject, $ldapData{firstname}, $hr);

		my $mobile = $ldapData{mobile};
		if ($mobile ne '') {
			my $mobLen = length $mobile;
			if ($mobLen == 10 || $mobile =~ /^\+?91\d{10}$/) {
				$mobile = substr $mobile, -10;
				$mobile = "91".$mobile;

				# Send message to the registered mobile of the user
				my $mesg = "Your profile has been successfully created. Account details (username/password): ".$ldapData{uid}."/pramati123. To change password details, login at auth.pramati.com";
				my $mobURL = $lconfig{sms_host}.'?ID='.$lconfig{sms_user}.'&Pwd='.$lconfig{sms_pwd}.'&PhNo='.$mobile.'&Text='.$mesg;
				my $confirm = get $mobURL;
				UsrMgmTl::PLog::plog("PLDAP::create: Message sent to mobile '$mobile'. Status: $confirm", ('debug')); 
			}
		}
	
		if ($lconfig{qontext_enabled} eq '1') {
			$info = '{\"emailAddress\":\"'.$ldapData{mail}.'\", \"password\":\"'.$ldapData{userpassword}.'\"}';
			UsrMgmTl::PDBI::insert_event($dbh, 'Qontext', 'Create', 0, 0, $invokedBy, $info);
		}
		if ($lconfig{mailacc_enabled} eq '1' && $ldapData{mailboxAcc} ne '') {
			$info = '{"Email":"'.$ldapData{mail}.'", "UID":"'.$ldapData{uid}.'", "mailboxAcc":"'.$ldapData{mailboxAcc}.'","firstname":"'.$ldapData{firstname}.'","lastname":"'.$ldapData{lastname}.'"}';
			UsrMgmTl::PDBI::insert_event($dbh, 'Mail','Create', 0, 0, $invokedBy, $info);
		}
	}
	UsrMgmTl::PLog::plog('PLDAP::create: End', ('debug'));
	$ldap->unbind;	
}

sub remove {
	my ($dbh, $rowId, $attempts, $invokedBy, $invokedAt, $jsonData) = @_;
	UsrMgmTl::PLog::plog('PLDAP::remove: Start', ('debug'));

	my %ldapData = %{from_json($jsonData)};
	my $ldap = &init();
	my @dnComp, $uid, $email, $info, $subject, $desc, $to, $cc, $from, $cn, $mailboxAcc, $firstName, $lastName;
	my $releavingData = UsrMgmTl::PLog::getTodayDate();

	my $result = $ldap->modify($ldapData{dn}, replace => {"personstatus" => 0, "releavingDate" => $releavingData});
	@dnComp = split(/,/, $ldapData{dn});
	$uid = substr($dnComp[0],4);
	if ($result->is_error) {
		UsrMgmTl::PLog::plog("Delete: Error deleting user with uid '$uid'. Error: ".$result->error, ('error','debug'));
		UsrMgmTl::PDBI::update_event($dbh, $rowId, 0, $result->error);		

		$info = "{UID:".$uid."}";
		$to=$lconfig{NTFY_ERROR_TO};
		$cc=$lconfig{NTFY_ERROR_CC};
		$from=$lconfig{NTFY_ERROR_FROM};
		$subject = "Error - User Management Tool : LDAP (Delete)";
		UsrMgmTl::PEmail::ErrorNotification($to, $cc, $from, $subject, $rowId, 'LDAP', 'Delete', $invokedBy, $invokedAt, $attempts, $info, $result->error);
	} else {
		UsrMgmTl::PLog::plog("LDAP (Delete): Deleted user with uid '$uid'", ('audit','debug'));
		UsrMgmTl::PDBI::update_event($dbh, $rowId, 1, '');		

		$info = "{UID:".$uid."}";
		$to=$lconfig{NTFY_LDAP_OP_TO};
		$cc=$lconfig{NTFY_LDAP_OP_CC};
		$from=$lconfig{NTFY_LDAP_OP_FROM};
		$subject = "Event - User Management Tool : LDAP (Delete)";
		$desc = "User Management Tool successfully executed delete user (LDAP) request. Details";
		UsrMgmTl::PEmail::Notification($to, $cc, $from, $subject, $rowId, 'LDAP', 'Delete', $invokedBy, $invokedAt, $attempts, $info, $desc);

		$firstName = &getPropertyByUid($uid, 'firstname');
		$lastName = &getPropertyByUid($uid, 'lastname');
		$email = &getPropertyByUid($uid, 'mail');
		$mailboxAcc = &getMailAccDomainByEmail($email);		

		# Change the dn to ExEmployee
		$cn = &getPropertyByUid($uid, 'cn');
		$ldap->moddn($ldapData{dn}, newrdn => "cn=$cn", newsuperior  => "ou=ExEmployees,dc=pramati,dc=com");
		
		if ($lconfig{qontext_enabled} eq '1') {
			$info = &getPropertyByUid($uid, 'mail');
			UsrMgmTl::PDBI::insert_event($dbh, 'Qontext', 'Delete', 0, 0, $invokedBy, $info);
		}
		if ($lconfig{mailacc_enabled} eq '1') {
			$info = '{"Email":"'.$email.'", "UID":"'.$uid.'","mailboxAcc":"'.$mailboxAcc.'","firstname":"'.$firstName.'","lastname":"'.$lastName.'"}';
			UsrMgmTl::PDBI::insert_event($dbh, 'Mail','Delete', 0, 0, $invokedBy, $info);
		}		
	}
	UsrMgmTl::PLog::plog('PLDAP::remove: End', ('debug'));
	$ldap->unbind;
}

sub resetPwd {
	my ($dbh, $rowId, $attempts, $invokedBy, $invokedAt, $jsonData) = @_;
	UsrMgmTl::PLog::plog('PLDAP::resetPwd: Start', ('debug'));

	my %ldapData = %{from_json($jsonData)};
	my $ldap = &init();
	my @dnComp, $uid, $info, $subject, $desc, $to, $cc, $from;

	my $result = $ldap->modify($ldapData{dn}, replace => {"pwdReset" => 'TRUE'});
	@dnComp = split(/,/, $ldapData{dn});
	$uid = substr($dnComp[0],4);
	if ($result->is_error) {
		UsrMgmTl::PLog::plog("Reset: Error resetting password for user with uid '$uid'. Error: ".$result->error, ('error','debug'));
		UsrMgmTl::PDBI::update_event($dbh, $rowId, 0, $result->error);		

		$info = "{UID:".$uid."}";
		$to=$lconfig{NTFY_ERROR_TO};
		$cc=$lconfig{NTFY_ERROR_CC};
		$from=$lconfig{NTFY_ERROR_FROM};
		$subject = "Error - User Management Tool : LDAP (Reset)";
		UsrMgmTl::PEmail::ErrorNotification($to, $cc, $from, $subject, $rowId, 'LDAP', 'Reset', $invokedBy, $invokedAt, $attempts, $info, $result->error);
	} else {
		UsrMgmTl::PLog::plog("LDAP (Reset): Password Reset for user with uid '$uid'", ('audit','debug'));
		UsrMgmTl::PDBI::update_event($dbh, $rowId, 1, '');		

		$info = "{UID:".$uid."}";
		$to=$lconfig{NTFY_LDAP_OP_TO};
		$cc=$lconfig{NTFY_LDAP_OP_CC};
		$from=$lconfig{NTFY_LDAP_OP_FROM};
		$subject = "Event - User Management Tool : LDAP (Reset)";
		$desc = "User Management Tool successfully executed reset password (LDAP) request. Details";
		UsrMgmTl::PEmail::Notification($to, $cc, $from, $subject, $rowId, 'LDAP', 'Reset', $invokedBy, $invokedAt, $attempts, $info, $desc);
	}
	UsrMgmTl::PLog::plog('PLDAP::resetPwd: End', ('debug'));
	$ldap->unbind;
}

sub update {
	my ($dbh, $rowId, $attempts, $invokedBy, $invokedAt, $jsonData) = @_;
	UsrMgmTl::PLog::plog('PLDAP::update: Start', ('debug'));

	my %ldapData = %{from_json($jsonData, { utf8  => 1 })};
	my $ldap = &init();
	my $info, $subject, $desc, $to, $cc, $from;

	my %previousDetails = getDetailsByUid($ldapData{uid});
	my $result = $ldap->modify($ldapData{dn}, replace => {"alternatemail" => $ldapData{alternatemail}, "birthdate" => $ldapData{birthdate}, "mobile" => $ldapData{mobile}, "department" => $ldapData{department}, "location" => $ldapData{location}, "title" => $ldapData{title}, "postalAddress" => $ldapData{postalAddress}, "homePostalAddress" => $ldapData{homePostalAddress}});
	if ($result->is_error) {
		UsrMgmTl::PLog::plog("Update: Error updating for user with uid '".$ldapData{uid}."'. Error: ".$result->error, ('error','debug'));
		UsrMgmTl::PDBI::update_event($dbh, $rowId, 0, $result->error);		

		$info = "{UID:".$ldapData{uid}."}";
		$to=$lconfig{NTFY_ERROR_TO};
		$cc=$lconfig{NTFY_ERROR_CC};
		$from=$lconfig{NTFY_ERROR_FROM};
		$subject = "Error - User Management Tool : LDAP (Update)";
		UsrMgmTl::PEmail::ErrorNotification($to, $cc, $from, $subject, $rowId, 'LDAP', 'Update', $invokedBy, $invokedAt, $attempts, $info, $result->error);
	} else {
		UsrMgmTl::PLog::plog("LDAP (Update): Updated details for user with uid '".$ldapData{uid}."'", ('audit','debug'));
		UsrMgmTl::PDBI::update_event($dbh, $rowId, 1, '');		

		$to=$ldapData{email};
		$cc=$lconfig{NTFY_LDAP_OP_CC};
		$from=$lconfig{NTFY_LDAP_OP_FROM};
		$subject = "LDAP - Profile Updated Successfully";
		UsrMgmTl::PEmail::profileUpdateNotification($to, $cc, $from, $subject, \%previousDetails, \%ldapData);

		if ($lconfig{qontext_enabled} eq '1') {
			UsrMgmTl::PDBI::insert_event($dbh, 'Qontext', 'Update', 0, 0, $invokedBy, $jsonData);
		}
	}
	UsrMgmTl::PLog::plog('PLDAP::update: End', ('debug'));
	$ldap->unbind;
}

sub forgotPwd {
	my ($dbh, $rowId, $attempts, $invokedBy, $invokedAt, $jsonData) = @_;
	UsrMgmTl::PLog::plog('PLDAP::forgotPwd: Start', ('debug'));

	my %ldapData = %{from_json($jsonData)};
	my $ldap = &init();
	my @dnComp, $uid, $info, $subject, $desc, $to, $cc, $from;
	
	my $userpassword = "{CRYPT}".crypt('pramati123', 'EO');
	my $result = $ldap->modify($ldapData{dn}, replace => {"userpassword" => $userpassword, "pwdReset" => 'TRUE'});
	@dnComp = split(/,/, $ldapData{dn});
	$uid = substr($dnComp[0],4);
	if ($result->is_error) {
		UsrMgmTl::PLog::plog("Forgot: Error making password default for user with uid '$uid'. Error: ".$result->error, ('error','debug'));
		UsrMgmTl::PDBI::update_event($dbh, $rowId, 0, $result->error);		

		$info = "{UID:".$uid."}";
		$to=$lconfig{NTFY_ERROR_TO};
		$cc=$lconfig{NTFY_ERROR_CC};
		$from=$lconfig{NTFY_ERROR_FROM};
		$subject = "Error - User Management Tool : LDAP (Forgot Password)";
		UsrMgmTl::PEmail::ErrorNotification($to, $cc, $from, $subject, $rowId, 'LDAP', 'Forgot', $invokedBy, $invokedAt, $attempts, $info, $result->error);
	} else {
		UsrMgmTl::PLog::plog("LDAP (Forgot): Password set to default for user with uid '$uid'", ('audit','debug'));
		UsrMgmTl::PDBI::update_event($dbh, $rowId, 1, '');		

		$info = "{UID:".$uid."}";
		$to=$lconfig{NTFY_LDAP_OP_TO};
		$cc=$lconfig{NTFY_LDAP_OP_CC};
		$from=$lconfig{NTFY_LDAP_OP_FROM};
		$subject = "Event - User Management Tool : LDAP (Forgot Password)";
		$desc = "User Management Tool successfully executed forgot password (LDAP) request. Details";
		UsrMgmTl::PEmail::Notification($to, $cc, $from, $subject, $rowId, 'LDAP', 'ForgotPwd', $invokedBy, $invokedAt, $attempts, $info, $desc);

		my $mobile = &getPropertyByUid($uid, 'mobile');
		if ($mobile ne '') {
			my $mobLen = length $mobile;
			if ($mobLen == 10 || $mobile =~ /^\+?91\d{10}$/) {
				$mobile = substr $mobile, -10;
				$mobile = "91".$mobile;

				# Send message to the registered mobile of the user
				my $mesg = "Your password on Pramati LDAP server has been reset to pramati123. Kindly try logging in now.";
				my $mobURL = $lconfig{sms_host}.'?ID='.$lconfig{sms_user}.'&Pwd='.$lconfig{sms_pwd}.'&PhNo='.$mobile.'&Text='.$mesg;
				my $confirm = get $mobURL;
				UsrMgmTl::PLog::plog("PLDAP::forgotPwd: Message sent to mobile '$mobile'. Status: $confirm", ('debug')); 
			}
		}

		if ($lconfig{qontext_enabled} eq '1') {
			$info = &getPropertyByUid($uid, 'mail');
			UsrMgmTl::PDBI::insert_event($dbh, 'Qontext', 'Forgot', 0, 0, $invokedBy, $info);
		}
	}
	UsrMgmTl::PLog::plog('PLDAP::forgotPwd: End', ('debug'));
	$ldap->unbind;
}


sub getBUs {
	#Todo: Write logic to pull BUs from ldap
	#my %bu = (
	#	'imaginea' => 'Imaginea',
	#	'pramati' => 'Pramati Corporate BU',
	#	'middleware' => 'Middleware',
	#	'qontext' => 'Qontext',
	#	'socialtwist' => 'SocialTwist',
	#	'gna' => 'G & A',
	#	'corp' => 'Corp',
	#	'appserver' => 'App Server'
	#);

	# This BU list corresponds to the ones defined on Qontext
	my %bu = (
		'imaginea' => 'Imaginea',
		'middleware' => 'Middleware',
		'pramati' => 'Pramati Corporate BU',
		'qontext' => 'Qontext',
		'socialtwist' => 'SocialTwist'
	); 
	return %bu;
}

sub getLocations {
	#Todo: Write logic to pull locations for centralized source (LDAP or Qontext)
	my %loc = (
		'Ascendas IT Park, Hyderabad' => 'Ascendas IT Park, Hyderabad',
		'Chennai' => 'Chennai',
		'USA' => 'USA',
		'White House, Hyderabad' => 'White House, Hyderabad'
	);
	return %loc;
}

sub getPropertyByUid {
	my ($uid, $attr) = @_;

	my $ldap = &init();
	my $mesg = $ldap->search(filter=>"(uid=$uid)", base=>$lconfig{ldap_basedn});
	my $res = $mesg->count;
	if ($res ne '0') {	
		my @entries = $mesg->entries;
		return $entries[0]->get_value($attr);
	} else {
		return '';
	}
}

sub getDetailsByUid {
	my ($uid) = @_;
	UsrMgmTl::PLog::plog('PLDAP::getDetailsByUid: Start', ('debug'));
	my $ldap = &init();
	my $mesg = $ldap->search(filter=>"(uid=$uid)", base=>$lconfig{ldap_basedn});
	UsrMgmTl::PLog::plog('PLDAP::getDetailsByUid: User details found: '.$mesg->count, ('debug'));	
	my @entries = $mesg->entries;
	my %details;	

	foreach my $entry (@entries) {
		$details{dn} = $entry->dn();
		@attrs = $entry->attributes();
        	foreach $attr (@attrs) {
			$details{$attr} = $entry->get_value($attr);
        	}
	}
	UsrMgmTl::PLog::plog('PLDAP::getDetailsByUid: End', ('debug'));
	return %details;
}

sub getMailAccDomainByEmail {
	my ($email) = @_;
	return	substr ($email, index($email, '@')+1, -4);
}
1;
