#!/usr/bin/perl

use CGI qw/:standard/;
use UsrMgmTl::Init;

my $type = param('type');
my $dbh, $res='',$inputData='';
if (defined($type) && $type eq 'email') {
	$res = UsrMgmTl::PLDAP::search('email', param('email'));
} elsif (defined($type) && $type eq 'uid') {
	$res = UsrMgmTl::PLDAP::search('uid', param('uid'));
} elsif (defined($type) && $type eq "939f69b4463c2ebb4a9def3fd52e7818d6c331c6") {
	$inputData = '{"dn":"'.param('dn').'","alternatemail":"'.param('alternatemail').'","birthdate":"'.param('birthdate').'","businessunit":"'.param('businessunit').'","department":"'.param('department').'","employeenumber":"'.param('employeenumber').'","cn":"'.param('cn').'","firstname":"'.param('firstname').'","gecos":"'.param('gecos').'","gidnumber":"'.param('gidnumber').'","homedirectory":"'.param('homedirectory').'","joiningdate":"'.param('joiningdate').'","loginshell":"'.param('loginshell').'","mail":"'.param('mail').'","lastname":"'.param('lastname').'","location":"'.param('location').'","mobile":"'.param('mobile').'","personstatus":"'.param('personstatus').'","sn":"'.param('sn').'","uid":"'.param('uid').'","uidnumber":"'.param('uidnumber').'","userpassword":"'.param('userpassword').'","title":"'.param('title').'","releavingDate":"'.param('releavingDate').'","homePostalAddress":"'.param('homePostalAddress').'","postalAddress":"'.param('postalAddress').'","mailboxAcc":"'.param('mailboxAcc').'"}';
	# insert_event(DBHandler, Category, Operation, Status, Attempts, InvokedBy, InputData)
	$dbh = UsrMgmTl::PDBI::init();	
	$res = UsrMgmTl::PDBI::insert_event($dbh, 'LDAP','Create', 0, 0, $ENV{REMOTE_USER}, $inputData);
	if ($res eq 'success') {
		UsrMgmTl::PLog::plog("LDAP (Create): Invoked 'create' user with uid '".param('uid')."'", ('audit'));
	}
	$dbh->disconnect();
} elsif (defined($type) && $type eq 'search') {
	$res = UsrMgmTl::PLDAP::search('search', param('search'), param('option'));
} elsif (defined($type) && $type eq "d3b31aaecef4737e63a2ec5718019831e490350a") {
	$dbh = UsrMgmTl::PDBI::init();	
	my $delDns = param('delDn');
	my $resetDns = param('resetDn');
	my $forgotDns = param('forgotDn');
	my @dns,@dnComp,$uid;

	if ($delDns ne '') {
		@dns = split(/:/, $delDns);
		foreach my $dn (@dns) {
			$inputData = '{"dn":"'.$dn.'"}';
			$res = UsrMgmTl::PDBI::insert_event($dbh, 'LDAP','Delete', 0, 0, $ENV{REMOTE_USER}, $inputData);
			if ($res eq 'success') {
				@dnComp = split(/,/, $dn);
				$uid = substr($dnComp[0],4);
				UsrMgmTl::PLog::plog("LDAP (Delete): Invoked 'delete' user with uid '$uid'", ('audit'));
			}
		}
	}
	if ($resetDns ne '') {
		@dns = split(/:/, $resetDns);
		foreach my $dn (@dns) {
			$inputData = '{"dn":"'.$dn.'"}';
			$res = UsrMgmTl::PDBI::insert_event($dbh, 'LDAP','Reset', 0, 0, $ENV{REMOTE_USER}, $inputData);
			if ($res eq 'success') {
				@dnComp = split(/,/, $dn);
				$uid = substr($dnComp[0],4);
				UsrMgmTl::PLog::plog("LDAP (Reset): Invoked 'password reset' for user with uid '$uid'", ('audit'));
			}
		}
	}
	if ($forgotDns ne '') {
		@dns = split(/:/, $forgotDns);
		foreach my $dn (@dns) {
			$inputData = '{"dn":"'.$dn.'"}';
			$res = UsrMgmTl::PDBI::insert_event($dbh, 'LDAP','ForgotPwd', 0, 0, $ENV{REMOTE_USER}, $inputData);
			if ($res eq 'success') {
				@dnComp = split(/,/, $dn);
				$uid = substr($dnComp[0],4);
				UsrMgmTl::PLog::plog("LDAP (ForgotPwd): Invoked 'forgot password' for user with uid '$uid'", ('audit'));
			}
		}
	}
	$dbh->disconnect();
} elsif (defined($type) && $type eq "974186975ad054b1f0a1d721c7b064c4d8022744") {
	my @dnComp, $uid;
	my $orig_uid = $ENV{REMOTE_USER};
	@dnComp = split(/,/, param('dn'));
	$uid = substr($dnComp[0],4);
	
	if ($orig_uid eq $uid) {
		$inputData = '{"dn":"'.param('dn').'","alternatemail":"'.param('alternatemail').'","birthdate":"'.param('birthdate').'","mobile":"'.param('mobile').'","uid":"'.param('uid').'","email":"'.param('mail').'","department":"'.param('department').'","location":"'.param('location').'","title":"'.param('title').'","postalAddress":"'.param('postalAddress').'","homePostalAddress":"'.param('homePostalAddress').'"}';
		$inputData =~ s/\n/\\n/g;
		$inputData =~ s/\r/\\r/g;

		$dbh = UsrMgmTl::PDBI::init();	
		$res = UsrMgmTl::PDBI::insert_event($dbh, 'LDAP','Update', 0, 0, $ENV{REMOTE_USER}, $inputData);
		if ($res eq 'success') {
			UsrMgmTl::PLog::plog("LDAP (Update): Invoked 'update' for user with uid '$uid'", ('audit'));
		}
		$dbh->disconnect();
	}
}

print $res;
