#!/usr/bin/perl

use CGI qw/:standard/;
use UsrMgmTl::Init;

# Check the user has permission to view this page
my $canViewEventsTab = UsrMgmTl::PLDAP::authenticate('events');

my $cgi = new CGI;
if (defined($ENV{REMOTE_USER})) {
	print $cgi->header;

	print $cgi->start_html(
		-title => 'Update User Profile',
		-head => [
			$cgi->Link({
				'rel' => 'stylesheet',
				'type' => 'text/css',
				'href' => '/css/jquery-ui-1.8.18.custom.css'
				}), 
			$cgi->Link({
				'rel' => 'stylesheet',
				'type' => 'text/css',
				'href' => '/css/styles.css'
				}),
			$cgi->start_script({
				-type => 'text/javascript',
				-src => '/js/jquery-1.7.1.min.js'
				}), $cgi->end_script(),
			$cgi->start_script({
				-type => 'text/javascript',
				-src => '/js/jquery-ui-1.8.18.custom.min.js'
				}), $cgi->end_script(),
			$cgi->start_script({
				-type => 'text/javascript',
				-src => '/js/script_update.js'
				}), $cgi->end_script(),
			]
		);

	my $layout = UsrMgmTl::PTemplate::updateDetailsTemplate($canViewEventsTab);
	print $layout;
	
	print $cgi->end_html();
} else {
	my %lconfig = &UsrMgmTl::Init::readConfig();
	print $q->redirect( -URL => $lconfig{link_main});
}
