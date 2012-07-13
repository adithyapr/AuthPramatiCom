#!/usr/bin/perl

package UsrMgmTl::PDBI;
use DBI;
use UsrMgmTl::PCrypt;

my %lconfig = &UsrMgmTl::Init::readConfig();

sub init {
	my $dbh;
	eval { $dbh = DBI->connect("dbi:SQLite:".$lconfig{db},"","",{ RaiseError => 1, sqlite_use_immediate_transaction => 1, }); };
	if ($@) {
		UsrMgmTl::PLog::plog("Failed to connect DB : $@", ('error', 'debug'));
		UsrMgmTl::PLog::plog("PDBI::init: DB: ".$lconfig{db}, ('debug'));
	} else {
		UsrMgmTl::PLog::plog("Connected to DB, ".$lconfig{db}, ('debug'));
	}
	return $dbh;
}	

sub insert_event {
	my ($dbh, $category, $operation, $status, $attempts, $invokedBy, $inputData) = @_;
	my $query, $sth;
	UsrMgmTl::PLog::plog('PDBI::insert_event: Start', ('debug'));

	my $res;
	if ($dbh) {
		#ID, Category, Operation, Status, Attempts, InvokedBy, InvokedAt, LastAttemptAt, InputData, ErrorMessage, Comment
		$sth = $dbh->prepare("INSERT INTO events_log (ID, Category, Operation, Status, Attempts, InvokedBy, InvokedAt, LastAttemptAt, InputData, ErrorMessage, Comment) VALUES (null, ?, ?, ?, ?, ?, datetime(), datetime(), ?, '', '')");
		#$query = "INSERT INTO events_log VALUES (null, '$category', '$operation', $status, $attempts, '$invokedBy', datetime(), datetime(), '$inputData', '', '')";
		#UsrMgmTl::PLog::plog("Query: $query", ('debug'));
		#eval { $dbh->do($query); };
		eval { $sth->execute($category, $operation, $status, $attempts, $invokedBy, $inputData); };
		if ($@) { 
			UsrMgmTl::PLog::plog("Failed to execute `events_log` INSERT stmt. DBError: ".$DBI::errstr.", SysError: ".$@, ('error', 'debug'));
			#UsrMgmTl::PLog::plog("Query: $query", ('error'));			
			$res = 'error';
		} else {
			UsrMgmTl::PLog::plog("Successfully executed `events_log` INSERT stmt.", ('debug'));
			$res = 'success';
		}
	}
	UsrMgmTl::PLog::plog('PDBI::insert_event: End', ('debug'));
	return $res;
}

sub update_event {
	my ($dbh, $rowId, $status, $error_msg, $type) = @_;
	my $query;
	UsrMgmTl::PLog::plog('PDBI::update_event: Start', ('debug'));

	if ($dbh) {
		if (defined($type) && $type eq 'hash') {
			$query = "UPDATE events_log SET InputData='', Status=$status, Attempts=Attempts+1, LastAttemptAt=datetime(), ErrorMessage=".$dbh->quote($error_msg)." WHERE ID=$rowId";
		} else {
			$query = "UPDATE events_log SET Status=$status, Attempts=Attempts+1, LastAttemptAt=datetime(), ErrorMessage=".$dbh->quote($error_msg)." WHERE ID=$rowId";
		}
		UsrMgmTl::PLog::plog("Query: $query", ('debug'));
		eval { $dbh->do($query); };
		if ($@) { 
			UsrMgmTl::PLog::plog("Failed to execute `events_log` UPDATE stmt. DBError: ".$DBI::errstr.", SysError: ".$@, ('error', 'debug'));
			UsrMgmTl::PLog::plog("Query: $query", ('error'));
		} else {
			UsrMgmTl::PLog::plog("Successfully executed `events_log` UPDATE stmt.", ('debug'));
		}
	}
	UsrMgmTl::PLog::plog('PDBI::update_event: End', ('debug'));
}

sub insert_event_with_hash {
	my ($dn, $password, $invokedBy) = @_;
	my $hash,$query, $inputData, $sth;
	UsrMgmTl::PLog::plog('PDBI::insert_event_with_hash: Start', ('debug'));

	if ($lconfig{qontext_enabled} eq '1') {	
		my $dbh = &init();
		if ($dbh) {
			$hash = UsrMgmTl::PCrypt::encode($password);
			$inputData = "{\"dn\":\"$dn\",\"password\":\"$hash\"}";
			$sth = $dbh->prepare("INSERT INTO events_log (ID, Category, Operation, Status, Attempts, InvokedBy, InvokedAt, LastAttemptAt, InputData, ErrorMessage, Comment) VALUES (null, 'Qontext', 'Reset', 0, 0, ?, datetime(), datetime(), ?, '', '')");
			eval { $sth->execute($invokedBy, $inputData); };
			if ($@) { 
				UsrMgmTl::PLog::plog("Failed to execute `events_log` INSERT (hash) stmt. DBError: ".$DBI::errstr.", SysError: ".$@, ('error', 'debug'));			
			} else {
				UsrMgmTl::PLog::plog("Successfully executed `events_log` INSERT (hash) stmt.", ('debug'));
			}
		}
	}
	UsrMgmTl::PLog::plog('PDBI::insert_event_with_hash: End', ('debug'));
}

sub get_events_log {
	my $dbh=&init;
	my $query,$sth,$id, $category, $operation, $status, $attempts, $invokedBy, $invokedAt, $lastAttempt,$i, $className;
	my $res = '';
	UsrMgmTl::PLog::plog('PDBI::get_events_log: Start', ('debug'));

	$limit = $lconfig{log_events_display_count};
	if ($dbh) {
		$query = "SELECT ID, Category, Operation, Status, Attempts, InvokedBy, InvokedAt, LastAttemptAt FROM events_log ORDER BY InvokedAt DESC LIMIT $limit";
		UsrMgmTl::PLog::plog("Query: $query", ('debug'));

		eval { $sth  = $dbh->prepare($query); }; 
		if ($@) { 
			UsrMgmTl::PLog::plog("Failed to prepare `events_log` SELECT stmt. DBError: ".$DBI::errstr.", SysError: ".$@, ('error', 'debug'));
			UsrMgmTl::PLog::plog("Query: $query", ('error'));
		} else {
			eval { $sth->execute; };
			if ($@) { 
				UsrMgmTl::PLog::plog("Failed to execute `events_log` SELECT stmt. DBError: ".$DBI::errstr.", SysError: ".$@, ('error', 'debug'));
			} else {
				$i=1;
				while ( ($id, $category, $operation, $status, $attempts, $invokedBy, $invokedAt, $lastAttempt) = $sth->fetchrow_array() ) {
					$className = '';
					if ($i%2 == 0) {
						$className = "class='rowEven'";
					}
					if ($status == 0 && $attempts == 0) {
						$status = "Not Initiated";
					} elsif ($status == 0 && $attempts > 0) {
						$status = "Failed";
					} else {
						$status = "Success";
					}
					$res .= "<tr $className><td>$id</td><td>$category</td><td>$operation</td><td>$status</td><td>$attempts</td><td>$invokedBy</td><td>$invokedAt</td><td>$lastAttempt</td></tr>";						
					$i++;
				}
			}
		}
	}
	if ($res eq '') {
		$res = "<tr><td colspan='8'> Zero records returned. Could be either Error or there are no events in the log</td></tr>";
	}
	UsrMgmTl::PLog::plog('PDBI::get_events_log: End', ('debug'));
	return $res;
}

sub set_process {
	my ($dbh, $eventId, $processFlag) = @_;

	eval { $dbh->do("UPDATE events_log SET InProcess=$processFlag WHERE ID=$eventId"); };
	if ($@) {
		UsrMgmTl::PLog::plog("Failed to execute `events_log` process update stmt DBError: ".$DBI::errstr.", SysError: ".$@, ('debug','error'));
	}
}

sub insert_mail_log {
	my ($dbh, $eventId, $type, $status, $inputData) = @_;
	UsrMgmTl::PLog::plog('PDBI::insert_mail_log: Start', ('debug'));

	my $res;
	if ($dbh) {
		eval { $dbh->do(); };
		if ($@) { 
			UsrMgmTl::PLog::plog("Failed to execute `mails_log` INSERT stmt. DBError: ".$DBI::errstr.", SysError: ".$@, ('error', 'debug'));
		} else {
			UsrMgmTl::PLog::plog("Successfully executed `mails_log` INSERT stmt.", ('debug'));
		}
	}
	UsrMgmTl::PLog::plog('PDBI::insert_mail_log: End', ('debug'));
}
	
1;
