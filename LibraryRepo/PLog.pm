#!/usr/bin/perl

package UsrMgmTl::PLog;
use POSIX qw/strftime ceil/;
use Time::Local;

my %lconfig = &UsrMgmTl::Init::readConfig();
my $logFormat = '['.strftime("%a %b %d  %H:%M:%S %Y",localtime);
if (defined($ENV{REMOTE_USER})) {
	$logFormat = $logFormat.'] ['.$ENV{REMOTE_USER}.'@'.$ENV{REMOTE_ADDR}.'] ';
} else {
	$logFormat = $logFormat.'] [UserManagmentTool@Scheduler] ';
}

sub plog {
	my ($log_mesg, @log_files) = @_;
	

	open AUDIT, ">>", $lconfig{log_path}.'audit.log' or die $!;
	open ERROR, ">>", $lconfig{log_path}.'error.log' or die $!;
	open DEBUG, ">>", $lconfig{log_path}.'debug.log' or die $!;

	foreach $log_file (@log_files) {
		if ($log_file eq 'audit' && $lconfig{log_audit} eq '1') {
			print AUDIT $logFormat.$log_mesg."\n";
		}
		elsif ($log_file eq 'error' && $lconfig{log_error} eq '1') {
			print ERROR $logFormat.$log_mesg."\n";
		}			
		elsif ($log_file eq 'debug' && $lconfig{log_debug} eq '1') {
			print DEBUG $logFormat.$log_mesg."\n";
		}
	}

	close AUDIT;
	close ERROR;
	close DEBUG;
}

sub getTodayDate {
	return strftime("%d/%m/%Y",localtime);
}

sub getDaysBetween {
	my ($pastDate) = @_;
	
	my ($day, $mon, $year) = split /\//, $pastDate;
	if ($day eq '00' || $day eq 0) {
		return 181; # Hardcoded since, no relieving date is set;
	} else {
		$pastTS = timelocal(0, 0, 0, $day, $mon, $year);
		return ceil( (time - $pastTS) / (24 * 60 * 60) );
	}
}
	
1;
