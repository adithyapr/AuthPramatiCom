#!/usr/bin/perl

use UsrMgmTl::Init;

my %lconfig = &UsrMgmTl::Init::readConfig();


while (1) {
	&initLDAPMgm;
	if ($lconfig{qontext_enabled} eq '1') {
		&initQontextMgm;
	}
	if ($lconfig{mailacc_enabled} eq '1') {
		&initMailAccMgm;
	}
	sleep(10);
}

sub initLDAPMgm {
	UsrMgmTl::PLog::plog('UsrMgmTl Script: initLDAPMgm --- Start ---', ('debug'));
	my $dbh = UsrMgmTl::PDBI::init();
	my ($sth, $ID, $Operation, $Attempts, $InvokedBy, $InvokedAt, $InputData);

	# Conditions
	# InProcess=0
	# Category = LDAP
	# Status = 0 (Failed)
	# Attempts <= Config(LDAP_ATTEMPTS); Attempts should be less than the defined limit set in config ini file
	# CurrentTimeStamp - LastAttemtpAt > Config(LDAP_ATTEMPT_GAP); Minimum gap should be maintained between successive attempts
	my $query = "SELECT ID, Operation, Attempts, InvokedBy, InvokedAt, InputData FROM events_log WHERE InProcess=0 AND Category='LDAP' AND Status=0 AND Attempts <= ".$lconfig{LDAP_ATTEMPTS}." AND (strftime('%s', 'now')-strftime('%s', LastAttemptAt)) > ".$lconfig{LDAP_ATTEMPTS_GAP};
	eval { $sth = $dbh->prepare($query); };
	if ($@) { 
		UsrMgmTl::PLog::plog("Failed to prepare `events_log` SELECT stmt. DBError: ".$DBI::errstr.", SysError: ".$@, ('error', 'debug'));
	} else {
		UsrMgmTl::PLog::plog("UserManagementTool Scheduler: LDAP query executed, $query", ('debug'));
		 ### Execute the statement in the database
		eval { $sth->execute; };
		if ($@) { 
			UsrMgmTl::PLog::plog("Failed to execute `events_log` SELECT stmt. DBError: ".$DBI::errstr.", SysError: ".$@, ('error', 'debug'));
		} else {
			$sth->bind_columns(\$ID, \$Operation, \$Attempts, \$InvokedBy, \$InvokedAt, \$InputData);
			while ($sth->fetch) {
				UsrMgmTl::PLog::plog("START --- Event ID: $ID, Operation: $Operation", ('debug')); 
				UsrMgmTl::PDBI::set_process($dbh, $ID, 1);
				if ($Operation eq 'Create') {
					UsrMgmTl::PLDAP::create($dbh, $ID, $Attempts, $InvokedBy, $InvokedAt, $InputData);
				} elsif ($Operation eq 'Delete') {
					UsrMgmTl::PLDAP::remove($dbh, $ID, $Attempts, $InvokedBy, $InvokedAt, $InputData);
				} elsif ($Operation eq 'Reset') {
					UsrMgmTl::PLDAP::resetPwd($dbh, $ID, $Attempts, $InvokedBy, $InvokedAt, $InputData);
				} elsif ($Operation eq 'Update') {
					UsrMgmTl::PLDAP::update($dbh, $ID, $Attempts, $InvokedBy, $InvokedAt, $InputData);
				} elsif ($Operation eq 'ForgotPwd') {
					UsrMgmTl::PLDAP::forgotPwd($dbh, $ID, $Attempts, $InvokedBy, $InvokedAt, $InputData);
				}
				UsrMgmTl::PDBI::set_process($dbh, $ID, 0);
				UsrMgmTl::PLog::plog("END --- Event ID: $ID, Operation: $Operation", ('debug'));
			}
		}
	}
	$dbh->disconnect();
	UsrMgmTl::PLog::plog('UsrMgmTl Script: initLDAPMgm --- End ---', ('debug'));
}

sub initQontextMgm {
	UsrMgmTl::PLog::plog('UsrMgmTl Script: initQontextMgm --- Start ---', ('debug'));
	my $dbh = UsrMgmTl::PDBI::init();
	my ($sth, $ID, $Operation, $Attempts, $InvokedBy, $InvokedAt, $InputData);

	# Conditions
	# Category = Qontext
	# Status = 0 (Failed)
	# Attempts <= Config(QONTEXT_ATTEMPTS); Attempts should be less than the defined limit set in config ini file
	# CurrentTimeStamp - LastAttemtpAt > Config(QONTEXT_ATTEMPT_GAP); Minimum gap should be maintained between successive attempts
	my $query = "SELECT ID, Operation, Attempts, InvokedBy, InvokedAt, InputData FROM events_log WHERE InProcess=0 AND Category='Qontext' AND Status=0 AND Attempts <= ".$lconfig{QONTEXT_ATTEMPTS}." AND (strftime('%s', 'now')-strftime('%s', LastAttemptAt)) > ".$lconfig{QONTEXT_ATTEMPTS_GAP};
	eval { $sth = $dbh->prepare($query); };
	if ($@) { 
		UsrMgmTl::PLog::plog("Failed to prepare `events_log` SELECT stmt. DBError: ".$DBI::errstr.", SysError: ".$@, ('error', 'debug'));
	} else {
		UsrMgmTl::PLog::plog("UserManagementTool Scheduler: Qontext query executed, $query", ('debug'));
		 ### Execute the statement in the database
		eval { $sth->execute; };
		if ($@) { 
			UsrMgmTl::PLog::plog("Failed to execute `events_log` SELECT stmt. DBError: ".$DBI::errstr.", SysError: ".$@, ('error', 'debug'));
		} else {
			$sth->bind_columns(\$ID, \$Operation, \$Attempts, \$InvokedBy, \$InvokedAt, \$InputData);
			while ($sth->fetch) {
				UsrMgmTl::PLog::plog("START --- Event ID: $ID, Operation: $Operation", ('debug'));
				UsrMgmTl::PDBI::set_process($dbh, $ID, 1); 
				if ($Operation eq 'Create') {
					UsrMgmTl::Qontext::create($dbh, $ID, $Attempts, $InvokedBy, $InvokedAt, $InputData);
				} elsif ($Operation eq 'Delete') {
					UsrMgmTl::Qontext::remove($dbh, $ID, $Attempts, $InvokedBy, $InvokedAt, $InputData);
				} elsif ($Operation eq 'Reset') {
					UsrMgmTl::Qontext::resetPwd($dbh, $ID, $Attempts, $InvokedBy, $InvokedAt, $InputData);
				} elsif ($Operation eq 'Update') {
					UsrMgmTl::Qontext::update($dbh, $ID, $Attempts, $InvokedBy, $InvokedAt, $InputData);
				} elsif ($Operation eq 'ForgotPwd') {
					UsrMgmTl::Qontext::updatePwd($dbh, $ID, $Attempts, $InvokedBy, $InvokedAt, $InputData);
				}
				UsrMgmTl::PDBI::set_process($dbh, $ID, 0);
				UsrMgmTl::PLog::plog("END --- Event ID: $ID, Operation: $Operation", ('debug'));
			}
		}
	}
	$dbh->disconnect();
	UsrMgmTl::PLog::plog('UsrMgmTl Script: initQontextMgm --- End ---', ('debug'));
}

sub initMailAccMgm {
	UsrMgmTl::PLog::plog('UsrMgmTl Script: initMailAccMgm --- Start ---', ('debug'));
	my $dbh = UsrMgmTl::PDBI::init();
	my ($sth, $ID, $Operation, $Attempts, $InvokedBy, $InvokedAt, $InputData);
	
	# Conditions
	# InProcess=0
	# Category = Mail (Mail Account)
	# Status = 0 (Failed)
	# Attempts <= Config(MAILACC_ATTEMPTS); Attempts should be less than the defined limit set in config ini file
	# CurrentTimeStamp - LastAttemtpAt > Config(MAILACC_ATTEMPT_GAP); Minimum gap should be maintained between successive attempts
	my $query = "SELECT ID, Operation, Attempts, InvokedBy, InvokedAt, InputData FROM events_log WHERE InProcess=0 AND Category='Mail' AND Status=0 AND Attempts <= ".$lconfig{MAILACC_ATTEMPTS}." AND (strftime('%s', 'now')-strftime('%s', LastAttemptAt)) > ".$lconfig{MAILACC_ATTEMPTS_GAP};
	eval { $sth = $dbh->prepare($query); };
	if ($@) { 
		UsrMgmTl::PLog::plog("Failed to prepare `events_log` SELECT stmt. DBError: ".$DBI::errstr.", SysError: ".$@, ('error', 'debug'));
	} else {
		UsrMgmTl::PLog::plog("UserManagementTool Scheduler: MailAcc query executed, $query", ('debug'));
		 ### Execute the statement in the database
		eval { $sth->execute; };	
		if ($@) { 
			UsrMgmTl::PLog::plog("Failed to execute `events_log` SELECT stmt. DBError: ".$DBI::errstr.", SysError: ".$@, ('error', 'debug'));
		} else {
			$sth->bind_columns(\$ID, \$Operation, \$Attempts, \$InvokedBy, \$InvokedAt, \$InputData);
			while ($sth->fetch) {
				UsrMgmTl::PLog::plog("START --- Event ID: $ID, Operation: $Operation", ('debug')); 
				UsrMgmTl::PDBI::set_process($dbh, $ID, 1);
				if ($Operation eq 'Create') {
					UsrMgmTl::PMailAcc::create($dbh, $ID, $Attempts, $InvokedBy, $InvokedAt, $InputData);
				} elsif ($Operation eq 'Delete') {
					UsrMgmTl::PMailAcc::remove($dbh, $ID, $Attempts, $InvokedBy, $InvokedAt, $InputData);
				} 
				UsrMgmTl::PDBI::set_process($dbh, $ID, 0);
				UsrMgmTl::PLog::plog("END --- Event ID: $ID, Operation: $Operation", ('debug'));
			}
		}
	}

	$dbh->disconnect();
	UsrMgmTl::PLog::plog('UsrMgmTl Script: initMailAccMgm --- End ---', ('debug'));
}	
