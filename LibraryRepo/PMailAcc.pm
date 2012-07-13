#!/usr/bin/perl

package UsrMgmTl::PMailAcc;
use JSON;
my %lconfig = &UsrMgmTl::Init::readConfig();

sub create {
	my ($dbh, $rowId, $attempts, $invokedBy, $invokedAt, $jsonData) = @_;
	UsrMgmTl::PLog::plog('PMailAcc::create: Start', ('debug'));

	my %ldapData = %{from_json($jsonData)};
	my @firstnameWords = split(' ', $ldapData{firstname});
	my $userId = lc(@firstnameWords[0].substr($ldapData{lastname},0,1));
	my $entity = lc(@firstnameWords[0].".".substr($ldapData{lastname},0,1));
	
	my $shellCmd = "sh ".$lconfig{mailacc_sh}." create ".$ldapData{mailboxAcc}." $entity $userId";
	$res = `$shellCmd`;
	chomp($res);
	if ($res eq '') {
		UsrMgmTl::PLog::plog("Mail Account (Create): Created mail account for user with uid '".$ldapData{UID}."'", ('audit','debug'));
		UsrMgmTl::PDBI::update_event($dbh, $rowId, 1, '');

		$info = "{Email:".$ldapData{Email}."}";
		$to=$lconfig{NTFY_LDAP_OP_TO};
		$cc=$lconfig{NTFY_LDAP_OP_CC};
		$from=$lconfig{NTFY_LDAP_OP_FROM};
		$subject = "Event - User Management Tool : Mail Account (Create)";
		$desc = "User Management Tool successfully executed create Mail Account request. Details";
		UsrMgmTl::PEmail::Notification($to, $cc, $from, $subject, $rowId, 'Mail', 'Create', $invokedBy, $invokedAt, $attempts, $info, $desc);
	} else {
		UsrMgmTl::PLog::plog("Create: Error creating mail account for user with uid '".$ldapData{UID}."'. Error: ".$res, ('error','debug'));
		UsrMgmTl::PDBI::update_event($dbh, $rowId, 0, $res);

		$info = "{Email:".$ldapData{Email}."}";
		$to=$lconfig{NTFY_ERROR_TO};
		$cc=$lconfig{NTFY_ERROR_CC};
		$from=$lconfig{NTFY_ERROR_FROM};
		$subject = "Error - User Management Tool : Mail Account (Create)";
		UsrMgmTl::PEmail::ErrorNotification($to, $cc, $from, $subject, $rowId, 'Mail', 'Create', $invokedBy, $invokedAt, $attempts, $info, $res);	
	}
	
	UsrMgmTl::PLog::plog('PMailAcc::create: End', ('debug'));
}

sub remove {
	my ($dbh, $rowId, $attempts, $invokedBy, $invokedAt, $jsonData) = @_;
	UsrMgmTl::PLog::plog('PMailAcc::remove: Start', ('debug'));

	my %ldapData = %{from_json($jsonData)};
	my @firstnameWords = split(' ', $ldapData{firstname});
	my $userId = lc(@firstnameWords[0].substr($ldapData{lastname},0,1));
	my $entity = lc(@firstnameWords[0].".".substr($ldapData{lastname},0,1));
	
	my $shellCmd = "sh ".$lconfig{mailacc_sh}." remove ".$ldapData{mailboxAcc}." $entity $userId";
	$res = `$shellCmd`;	
	chomp($res);
	if ($res eq '') {
		UsrMgmTl::PLog::plog("Mail Account (Delete): Deleted mail account for user with uid '".$ldapData{UID}."'", ('audit','debug'));
		UsrMgmTl::PDBI::update_event($dbh, $rowId, 1, '');	
			
		$info = "{Email:".$ldapData{Email}."}";
		$to=$lconfig{NTFY_LDAP_OP_TO};
		$cc=$lconfig{NTFY_LDAP_OP_CC};
		$from=$lconfig{NTFY_LDAP_OP_FROM};
		$subject = "Event - User Management Tool : Mail Account (Delete)";
		$desc = "User Management Tool successfully executed delete Mail Account request. Details";
		UsrMgmTl::PEmail::Notification($to, $cc, $from, $subject, $rowId, 'Mail', 'Delete', $invokedBy, $invokedAt, $attempts, $info, $desc);
	} else {
		UsrMgmTl::PLog::plog("Delete: Error deleting mail account for user with uid '".$ldapData{UID}."'. Error: ".$res, ('error','debug'));
		UsrMgmTl::PDBI::update_event($dbh, $rowId, 0, $res);		

		$info = "{Email:".$ldapData{Email}."}";
		$to=$lconfig{NTFY_ERROR_TO};
		$cc=$lconfig{NTFY_ERROR_CC};
		$from=$lconfig{NTFY_ERROR_FROM};
		$subject = "Error - User Management Tool : Mail Account (Delete)";
		UsrMgmTl::PEmail::ErrorNotification($to, $cc, $from, $subject, $rowId, 'Mail', 'Delete', $invokedBy, $invokedAt, $attempts, $info, $res);	
	}
	
	UsrMgmTl::PLog::plog('PMailAcc::remove: End', ('debug'));
}
	
1;	
