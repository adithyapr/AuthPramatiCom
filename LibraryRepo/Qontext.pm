#!/usr/bin/perl

package UsrMgmTl::Qontext;
use JSON;

my %lconfig = &UsrMgmTl::Init::readConfig();

sub create {
	my ($dbh, $rowId, $attempts, $invokedBy, $invokedAt, $jsonData) = @_;
	my $to,$cc,$from,$subject,$desc,$email;

	UsrMgmTl::PLog::plog('Qontext::create: Start', ('debug'));

	my $url = $lconfig{qontext_host}.'login/api/account';
	my $curlSyntax='curl  --basic -u'.$lconfig{qontext_user}.':'.$lconfig{qontext_pwd}.' -d "'.$jsonData.'" -XPUT -H "Accept:application/json" -H "Content-type:application/json" -k '.$url;
	UsrMgmTl::PLog::plog('Qontext::create: Curl: '.$curlSyntax, ('debug'));

	my $res = `$curlSyntax`;
	UsrMgmTl::PLog::plog('Qontext::create: Curl Response: '.$res, ('debug'));

	if ($res =~ /success/) {
		if ($jsonData =~ /emailAddress\\":\\"([\w@.]+)\\"/) {
			$email = $1;
		}
		UsrMgmTl::PLog::plog("Qontext (Create): Created user with email '$email'", ('audit','debug'));
		UsrMgmTl::PDBI::update_event($dbh, $rowId, 1, '');

		$to=$lconfig{NTFY_QONTEXT_CREATE_TO};
		$cc=$lconfig{NTFY_QONTEXT_CREATE_CC};
		$from=$lconfig{NTFY_QONTEXT_CREATE_FROM};
		$subject = "Event - User Management Tool : Qontext (Create)";
		$desc = "User Management Tool successfully executed create user (Qontext) request. Details";
		UsrMgmTl::PEmail::Notification($to, $cc, $from, $subject, $rowId, 'Qontext', 'Create', $invokedBy, $invokedAt, $attempts, $jsonData, $desc);
	} else {
		UsrMgmTl::PDBI::update_event($dbh, $rowId, 0, $res);

		$to=$lconfig{NTFY_ERROR_TO};
		$cc=$lconfig{NTFY_ERROR_CC};
		$from=$lconfig{NTFY_ERROR_FROM};
		$subject = "Error - User Management Tool : Qontext (Create)";
		UsrMgmTl::PEmail::ErrorNotification($to, $cc, $from, $subject, $rowId, 'Qontext', 'Create', $invokedBy, $invokedAt, $attempts, $jsonData, $res);
	}
	UsrMgmTl::PLog::plog('Qontext::create: End', ('debug'));
}

sub remove {
	my ($dbh, $rowId, $attempts, $invokedBy, $invokedAt, $email) = @_;
	my $to,$cc,$from,$subject,$desc;
	UsrMgmTl::PLog::plog('Qontext::remove: Start', ('debug'));

	my $accountId = &getAccountId($email); 
	my $jsonData = '{\"status\":\"inactive\"}';
	my $url = $lconfig{qontext_host}."login/api/account/$accountId/status";
	my $curlSyntax = 'curl --basic -u'.$lconfig{qontext_user}.':'.$lconfig{qontext_pwd}.' -d "'.$jsonData.'" -XPUT -H "Accept:application/json" -H "Content-type:application/json" -k '.$url;
	UsrMgmTl::PLog::plog('Qontext::remove: Curl: '.$curlSyntax, ('debug'));

	my $res = `$curlSyntax`;
	UsrMgmTl::PLog::plog('Qontext::remove: Curl Response: '.$res, ('debug'));
	
	if ($res =~ /success/) {
		UsrMgmTl::PLog::plog("Qontext (Delete): Deleted user with email '$email'", ('audit','debug'));
		UsrMgmTl::PDBI::update_event($dbh, $rowId, 1, '');

		$to=$lconfig{NTFY_QONTEXT_DELETE_TO};
		$cc=$lconfig{NTFY_QONTEXT_DELETE_CC};
		$from=$lconfig{NTFY_QONTEXT_DELETE_FROM};
		$subject = "Event - User Management Tool : Qontext (Delete)";
		$desc = "User Management Tool successfully executed delete user (Qontext) request. Details";
		UsrMgmTl::PEmail::Notification($to, $cc, $from, $subject, $rowId, 'Qontext', 'Delete', $invokedBy, $invokedAt, $attempts, $email, $desc);
	} else {
		UsrMgmTl::PDBI::update_event($dbh, $rowId, 0, $res);

		$to=$lconfig{NTFY_ERROR_TO};
		$cc=$lconfig{NTFY_ERROR_CC};
		$from=$lconfig{NTFY_ERROR_FROM};
		$subject = "Error - User Management Tool : Qontext (Delete)";
		UsrMgmTl::PEmail::ErrorNotification($to, $cc, $from, $subject, $rowId, 'Qontext', 'Delete', $invokedBy, $invokedAt, $attempts, $email, $res);
	}
	UsrMgmTl::PLog::plog('Qontext::remove: End', ('debug'));
}

sub resetPwd {
	my ($dbh, $rowId, $attempts, $invokedBy, $invokedAt, $jsonData) = @_;
	my $to,$cc,$from,$subject,$desc;
	UsrMgmTl::PLog::plog('Qontext::resetPwd: Start', ('debug'));

	if ($jsonData =~ /uid=([\w\d.]+),ou[\w=,"]+password":"([\s\S]+)"}/) {
		my $email = UsrMgmTl::PLDAP::getPropertyByUid($1, 'mail');
		my $accountId = &getAccountId($email); 

		my $password = UsrMgmTl::PCrypt::encode($2);
		$jsonData = '{\"password\":\"'.$password.'\"}';	
		my $url = $lconfig{qontext_host}."login/api/account/$accountId/password";
		my $curlSyntax = 'curl --basic -u'.$lconfig{qontext_user}.':'.$lconfig{qontext_pwd}.' -d "'.$jsonData.'" -XPUT -H "Accept:application/json" -H "Content-type:application/json" -k '.$url;
		#UsrMgmTl::PLog::plog('Qontext::resetPwd: Curl Syntax: '.$curlSyntax, ('debug')); #Comment it later
		my $res = `$curlSyntax`;
		UsrMgmTl::PLog::plog('Qontext::resetPwd: Curl Response: '.$res, ('debug'));
	
		if ($res =~ /success/) {
			UsrMgmTl::PLog::plog("Qontext (Reset): Password Reset for user with email '$email'", ('audit','debug'));
			UsrMgmTl::PDBI::update_event($dbh, $rowId, 1, '', 'hash');

			$to=$lconfig{NTFY_QONTEXT_RESET_TO};
			$cc=$lconfig{NTFY_QONTEXT_RESET_CC};
			$from=$lconfig{NTFY_QONTEXT_RESET_FROM};
			$subject = "Event - User Management Tool : Qontext (Reset)";
			$desc = "User Management Tool successfully executed reset password user (Qontext) request. Details";
			UsrMgmTl::PEmail::Notification($to, $cc, $from, $subject, $rowId, 'Qontext', 'Reset', $invokedBy, $invokedAt, $attempts, $email, $desc);

			$to=$email;
			$from=$lconfig{NTFY_QONTEXT_DELETE_FROM};
			$subject = "Qontext - Scuccessfully synchronized main system password to Qontext<EOM>";
			UsrMgmTl::PEmail::UserNotification($to, '', $from, $subject);
		} else {
			UsrMgmTl::PDBI::update_event($dbh, $rowId, 0, $res);

			$to=$lconfig{NTFY_ERROR_TO};
			$cc=$lconfig{NTFY_ERROR_CC};
			$from=$lconfig{NTFY_ERROR_FROM};
			$subject = "Error - User Management Tool : Qontext (Reset)";
			UsrMgmTl::PEmail::ErrorNotification($to, $cc, $from, $subject, $rowId, 'Qontext', 'Reset', $invokedBy, $invokedAt, $attempts, $email, $res);
		}
	}
	UsrMgmTl::PLog::plog('Qontext::resetPwd: End', ('debug'));
}

sub update {
	my ($dbh, $rowId, $attempts, $invokedBy, $invokedAt, $inputData) = @_;
	my $to,$cc,$from,$subject,$desc, $jsonData, $curlSyntax, $res, $error=0;
	UsrMgmTl::PLog::plog('Qontext::update: Start', ('debug'));

	my %ldapData = %{from_json($inputData)};
	my $accountId = &getAccountId($ldapData{email});
	my $url = $lconfig{qontext_host}."portal/api/profile/update";

	# Approach 1
	$jsonData = '{\"accountId\":\"'.$accountId.'\", \"profileFields\":[{\"fieldName\":\"DEPARTMENT\",\"value\":\"'.$ldapData{department}.'\"},{\"fieldName\":\"LOCATION\",\"value\":\"'.$ldapData{location}.'\"},{\"fieldName\":\"MOBILE\",\"value\":\"'.$ldapData{mobile}.'\"}]}';		
	$curlSyntax = 'curl --basic -u'.$lconfig{qontext_user}.':'.$lconfig{qontext_pwd}.' -d "'.$jsonData.'" -XPOST -H "Accept:application/json" -H "Content-type:application/json" -k '.$url;	
	
	UsrMgmTl::PLog::plog('Qontext::update: Curl: '.$curlSyntax, ('debug'));
	$res = `$curlSyntax`;
	if ($res =~ /success/) {
		UsrMgmTl::PLog::plog("Qontext (Update): Updated user profile with email '".$ldapData{email}."'", ('audit','debug'));
		UsrMgmTl::PDBI::update_event($dbh, $rowId, 1, '');

		$to=$ldapData{email};
		$cc=$lconfig{NTFY_QONTEXT_DELETE_TO};
		$from=$lconfig{NTFY_QONTEXT_DELETE_FROM};
		$subject = "Qontext - Profile Updated Successfully <EOM>";
		UsrMgmTl::PEmail::UserNotification($to, $cc, $from, $subject);
	} else {
		UsrMgmTl::PDBI::update_event($dbh, $rowId, 0, $res);

		$to=$lconfig{NTFY_ERROR_TO};
		$cc=$lconfig{NTFY_ERROR_CC};
		$from=$lconfig{NTFY_ERROR_FROM};
		$subject = "Error - User Management Tool : Qontext (Update)";
		UsrMgmTl::PEmail::ErrorNotification($to, $cc, $from, $subject, $rowId, 'Qontext', 'Update', $invokedBy, $invokedAt, $attempts, $ldapData{email}, $res);
	}

	# Approach 2
	#my %dataHash = ('DEPARTMENT' => $ldapData{department}, 'LOCATION' => $ldapData{location}, 'MOBILE' => $ldapData{mobile});

	#while (($key,$value) = each(%dataHash)) {
	#	$jsonData = '{\"accountId\":\"'.$accountId.'\", \"profileFields\":[{\"fieldName\":\"'.$key.'\",\"value\":\"'.$value.'\"}]}';		
	#	$curlSyntax = 'curl --basic -u'.$lconfig{qontext_user}.':'.$lconfig{qontext_pwd}.' -d "'.$jsonData.'" -XPOST -H "Accept:application/json" -H "Content-type:application/json" -k '.$url;	
	#	UsrMgmTl::PLog::plog('Qontext::update: Curl: '.$curlSyntax, ('debug'));
	#	$res = `$curlSyntax`;
	#	UsrMgmTl::PLog::plog('Qontext::update: Curl Response: '.$res, ('debug'));
	#	if (!($res =~ /success/)) {
	#		$error=1;
	#	}
	#}			

	#if ($error eq '0') {
	#	UsrMgmTl::PLog::plog("Qontext (Update): Updated user profile with email '".$ldapData{email}."'", ('audit','debug'));
	#	UsrMgmTl::PDBI::update_event($dbh, $rowId, 1, '');

	#	$to=$ldapData{email};
	#	$cc=$lconfig{NTFY_QONTEXT_DELETE_TO};
	#	$from=$lconfig{NTFY_QONTEXT_DELETE_FROM};
	#	$subject = "Qontext - Profile Updated Successfully <EOM>";
	#	UsrMgmTl::PEmail::UserNotification($to, $cc, $from, $subject);
	#} else {
	#	UsrMgmTl::PDBI::update_event($dbh, $rowId, 0, $res);

	#	$to=$lconfig{NTFY_ERROR_TO};
	#	$cc=$lconfig{NTFY_ERROR_CC};
	#	$from=$lconfig{NTFY_ERROR_FROM};
	#	$subject = "Error - User Management Tool : Qontext (Update)";
	#	UsrMgmTl::PEmail::ErrorNotification($to, $cc, $from, $subject, $rowId, 'Qontext', 'Update', $invokedBy, $invokedAt, $attempts, $ldapData{email}, $res);
	#}
	UsrMgmTl::PLog::plog('Qontext::update: End', ('debug'));
}

sub updatePwd {
	my ($dbh, $rowId, $attempts, $invokedBy, $invokedAt, $email) = @_;
	my $to,$cc,$from,$subject,$desc, $jsonData, $curlSyntax, $res, $error=0;
	UsrMgmTl::PLog::plog('Qontext::updatePwd: Start', ('debug'));

	my $accountId = &getAccountId($email);
	my $url = $lconfig{qontext_host}."login/api/account/$accountId/password";

	$jsonData = '{\"password\":\"pramati123\"}';		
	$curlSyntax = 'curl --basic -u'.$lconfig{qontext_user}.':'.$lconfig{qontext_pwd}.' -d "'.$jsonData.'" -XPUT -H "Accept:application/json" -H "Content-type:application/json" -k '.$url;	
	
	UsrMgmTl::PLog::plog('Qontext::update: Curl: '.$curlSyntax, ('debug'));
	$res = `$curlSyntax`;
	if ($res =~ /success/) {
		UsrMgmTl::PLog::plog("Qontext (Forgot): Default password updated for user profile with email '".$email."'", ('audit','debug'));
		UsrMgmTl::PDBI::update_event($dbh, $rowId, 1, '');

		$to=$email;
		$cc=$lconfig{NTFY_QONTEXT_DELETE_TO};
		$from=$lconfig{NTFY_QONTEXT_DELETE_FROM};
		$subject = "Qontext - Profile Updated with default password successfully <EOM>";
		UsrMgmTl::PEmail::UserNotification($to, $cc, $from, $subject);
	} else {
		UsrMgmTl::PDBI::update_event($dbh, $rowId, 0, $res);

		$to=$lconfig{NTFY_ERROR_TO};
		$cc=$lconfig{NTFY_ERROR_CC};
		$from=$lconfig{NTFY_ERROR_FROM};
		$subject = "Error - User Management Tool : Qontext (Default Password)";
		UsrMgmTl::PEmail::ErrorNotification($to, $cc, $from, $subject, $rowId, 'Qontext', 'Default Password', $invokedBy, $invokedAt, $attempts, $ldapData{email}, $res);
	}

	UsrMgmTl::PLog::plog('Qontext::updatePwd: End', ('debug'));
}


sub getAccountId {
	my ($email) = @_;
	UsrMgmTl::PLog::plog('Qontext::getAccountId: Start', ('debug'));
	my $accountId = 0;

	my $url = $lconfig{qontext_host}.'portal/api/profile/search';
	my $jsonData = '{\"profileFields\":[{\"fieldName\":\"EMAIL\",\"value\":\"'.$email.'\"}]}';	
	my $curlSyntax = 'curl --basic -u'.$lconfig{qontext_user}.':'.$lconfig{qontext_pwd}.' -d "'.$jsonData.'" -X POST -H "Accept:application/json" -H "Content-type:application/json" -k '.$url;
	UsrMgmTl::PLog::plog('Qontext::getAccountId: Curl: '.$curlSyntax, ('debug'));

	my $res = `$curlSyntax`;
	UsrMgmTl::PLog::plog('Qontext::getAccountId: Curl Response: '.$res, ('debug'));

	if ($res =~ /success/) {
		if ($res =~ /"accountId":"(\d+)"/) {
			$accountId = $1;
		}
	}
	UsrMgmTl::PLog::plog("Qontext::getAccountId: AccountId: $accountId", ('debug'));
	UsrMgmTl::PLog::plog('Qontext::getAccountId: End', ('debug'));
	return $accountId;
}

1;
