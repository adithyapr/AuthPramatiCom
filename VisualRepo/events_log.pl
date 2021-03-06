#!/usr/bin/perl

use CGI qw/:standard/;
use UsrMgmTl::Init;

# Check the user has permission to view this page
my $perm = UsrMgmTl::PLDAP::authenticate('events');

my $cgi = new CGI;
print $cgi->header;

if ($perm) {
	print $cgi->start_html(
		-title => 'Events Log',
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
				}), $cgi->end_script()
			]
		);
	my $layout = UsrMgmTl::PTemplate::eventsLogTemplate($perm);
	print $layout;
} else {
	print $cgi->start_html(
		-title => 'No Access',
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
				}), $cgi->end_script()
			]
		);

	my $layout = UsrMgmTl::PTemplate::noAccessTemplate('events',$perm);
	print $layout;
}

print $cgi->end_html();
