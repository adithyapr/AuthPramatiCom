#!/usr/bin/perl

use CGI qw/:standard/;
use UsrMgmTl::Init;

# Check the user has permission to view this page
my $perm = UsrMgmTl::PLDAP::authenticate('add');
my $canViewEventsTab = UsrMgmTl::PLDAP::authenticate('events');

my $cgi = new CGI;
print $cgi->header;

if ($perm) {
	my $uid = param("uid"); 
	if (defined($uid) && $uid ne '') {

		print $cgi->start_html(
			-title => 'Add Users to LDAP',
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
					-src => '/js/script_create.js'
					}), $cgi->end_script(),
				]
			);
		my $mailBoxAcc = '';			
		if ( !(param('bu') eq 'imaginea' || param('bu') eq 'pramati') ) {
			if (defined(param('chkmailbox'))) {
				$mailBoxAcc = param('optMailAcc');
			}
		} else {
			$mailBoxAcc = param('bu');
		}		

		my $layout = UsrMgmTl::PTemplate::addUserConfirmTemplate($uid,param('pemail'),param('dob'),param('bu'),param('fname'),param('lname'),param('doj'),param('empid'),param('oemail'),param('pmobile'),param('location'),param('designation'), $mailBoxAcc, $canViewEventsTab);
	
		print $layout;
	
	} else {

		print $cgi->start_html(
				-title => 'Add Users to LDAP',
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
						-src => '/js/script.js'
						}), $cgi->end_script(),
					]
				);

		my $layout = UsrMgmTl::PTemplate::addUserTemplate($canViewEventsTab);
		print $layout;
	}
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

	my $layout = UsrMgmTl::PTemplate::noAccessTemplate('add',$canViewEventsTab);
	print $layout;
}

print $cgi->end_html();
