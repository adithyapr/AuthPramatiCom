#!/usr/bin/perl

package UsrMgmTl::PEmail;
use MIME::Lite;
use HTML::Template;

my %lconfig = &UsrMgmTl::Init::readConfig();

sub sendEmail {
	my ($to, $cc, $from, $subject, $body, $type) = @_;

	my $msg = MIME::Lite->new
		(
			Subject => $subject,
			From    => $from,
			To      => $to,
			Cc	=> $cc,
			Type    => 'text/html',
			Data    => $body
		);
	#if (defined($type) && $type eq 'welcome') {
	#	$msg->attach(
	#		Type => 'image/jpeg',
	#		Id   => 'logo1.jpg',
	#		Path => $lconfig{APP_PATH}.'css/images/pramati.jpg',
	#	);
	#	$msg->attach(
	#		Type => 'image/jpeg',
	#		Id   => 'logo2.jpg',
	#		Path => $lconfig{APP_PATH}.'css/images/products.jpg',
	#	);		
	#}
	eval { $msg->send('smtp', $lconfig{mail_host}, AuthUser=>$lconfig{mail_user}, AuthPass=>$lconfig{mail_pwd}); };
	if ($@) {
		UsrMgmTl::PLog::plog("Failed to send EMAIL : $@", ('error', 'debug'));
		UsrMgmTl::PLog::plog("PEmail::sendEmail: Host: ".$lconfig{mail_host}.", AuthUser: ".$lconfig{mail_user}, ('debug'));
		UsrMgmTl::PLog::plog("PEmail::sendEmail: To: $to, Cc: $cc, From: $from, Subject: $subject", ('debug'));
		# Add UsrMgmTl::PDBI::insert_mail_log();
	} else {
		UsrMgmTl::PLog::plog("Sent EMAIL. To: $to, Subject: $subject", ('debug'));
		# Add UsrMgmTl::PDBI::update_mail_log();
	}
} 	

sub Notification {
	my ($to, $cc, $from, $subject, $rowId, $category, $operation, $invokedBy, $invokedAt, $attempts, $info, $desc) = @_;
	
	my $template = HTML::Template->new(filename => $lconfig{APP_PATH}.'templates/notification.tmpl');
	$template->param(DESC => $desc);
	$template->param(ROW_ID => $rowId);
	$template->param(CATEGORY => $category);
	$template->param(OPERATION => $operation);
	$template->param(INVOKEDBY => $invokedBy);
	$template->param(INVOKEDAT => $invokedAt);
	$template->param(ATTEMPTS => ++$attempts);
	$template->param(INFO => $info);

	my $email_body = $template->output;
	&sendEmail($to, $cc, $from, $subject, $email_body);	
}


sub ErrorNotification {
	my ($to, $cc, $from, $subject, $rowId, $category, $operation, $invokedBy, $invokedAt, $attempts, $info, $error_msg) = @_;
	
	my $template = HTML::Template->new(filename => $lconfig{APP_PATH}.'templates/error_notification.tmpl');
	$template->param(ROW_ID => $rowId);
	$template->param(CATEGORY => $category);
	$template->param(OPERATION => $operation);
	$template->param(INVOKEDBY => $invokedBy);
	$template->param(INVOKEDAT => $invokedAt);
	$template->param(ATTEMPTS => ++$attempts);
	$template->param(INFO => $info);
	$template->param(ERR_MSG => $error_msg);

	my $email_body = $template->output;
	&sendEmail($to, $cc, $from, $subject, $email_body);	
}

sub welcomeNotification {
	my ($to, $cc, $from, $subject, $fname, $hr) = @_;
	
	my $template = HTML::Template->new(filename => $lconfig{APP_PATH}.'templates/welcome.tmpl');
	$template->param(EMPNAME => $fname);
	my $email_body = $template->output;

	&sendEmail($to, $cc, $from, $subject, $email_body, 'welcome');
}

sub UserNotification {
	my ($to, $cc, $from, $subject) = @_;
	&sendEmail($to, $cc, $from, $subject, '');	
}

sub profileUpdateNotification {
	my ($to, $cc, $from, $subject, $refPrevious, $refCurrent) = @_;
	my $template = HTML::Template->new(filename => $lconfig{APP_PATH}.'templates/profile_update.tmpl');
	$template->param(USER => ${$refPrevious}{firstName});

	$template->param(PDOB => ${$refPrevious}{birthDate});
	$template->param(PEMAIL => ${$refPrevious}{alternateMail});
	$template->param(PMOB => ${$refPrevious}{mobile});
	$template->param(PTMPADDR => ${$refPrevious}{postalAddress});
	$template->param(PPERADDR => ${$refPrevious}{homePostalAddress});
	$template->param(PDES => ${$refPrevious}{title});
	$template->param(PDEP => ${$refPrevious}{department});
	$template->param(PLOC => ${$refPrevious}{location});

	$template->param(NDOB => ${$refCurrent}{birthdate});
	$template->param(NEMAIL => ${$refCurrent}{alternatemail});
	$template->param(NMOB => ${$refCurrent}{mobile});
	$template->param(NTMPADDR => ${$refCurrent}{postalAddress});
	$template->param(NPERADDR => ${$refCurrent}{homePostalAddress});
	$template->param(NDES => ${$refCurrent}{title});
	$template->param(NDEP => ${$refCurrent}{department});
	$template->param(NLOC => ${$refCurrent}{location});
	my $email_body = $template->output;

	&sendEmail($to, $cc, $from, $subject, $email_body);
}

1;
