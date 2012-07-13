#!/usr/bin/perl

package UsrMgmTl::Init;
use Config::IniFiles;

my %lconfig = &readConfig();
sub readConfig {
	my $cfg = new Config::IniFiles( -file => "/usr/local/UserManagementTool/config.ini" );
	#my $cfg = new Config::IniFiles( -file => "/var/lib/UserManagementTool/config.ini" );
	
	my %pconfig = (
			'SALT' => $cfg->exists('Crypt', 'SALT') ? $cfg->val('Crypt', 'SALT') : &configIssue('Crypt', 'SALT'),
			'CREATE' => $cfg->exists('Crypt', 'create') ? $cfg->val('Crypt', 'create') : &configIssue('Crypt', 'create'),
			'DELETE' => $cfg->exists('Crypt', 'delete') ? $cfg->val('Crypt', 'delete') : &configIssue('Crypt', 'delete'),
			'UPDATE' => $cfg->exists('Crypt', 'update') ? $cfg->val('Crypt', 'update') : &configIssue('Crypt', 'update'),
			'LDAP_ATTEMPTS' => $cfg->exists('Scheduler', 'LDAPAttempts') ? $cfg->val('Scheduler', 'LDAPAttempts') : &configIssue('Scheduler', 'LDAPAttempts'),
			'LDAP_ATTEMPTS_GAP' => $cfg->exists('Scheduler', 'LDAPAttemptsGap') ? $cfg->val('Scheduler', 'LDAPAttemptsGap') : &configIssue('Scheduler', 'LDAPAttemptsGap'),
			'QONTEXT_ATTEMPTS' => $cfg->exists('Scheduler', 'QontextAttempts') ? $cfg->val('Scheduler', 'QontextAttempts') : &configIssue('Scheduler', 'QontextAttempts'),
			'QONTEXT_ATTEMPTS_GAP' => $cfg->exists('Scheduler', 'QontextAttemptsGap') ? $cfg->val('Scheduler', 'QontextAttemptsGap') : &configIssue('Scheduler', 'QontextAttemptsGap'),
			'MAILACC_ATTEMPTS' => $cfg->exists('Scheduler', 'MailAccAttempts') ? $cfg->val('Scheduler', 'MailAccAttempts') : &configIssue('Scheduler', 'MailAccAttempts'),
			'MAILACC_ATTEMPTS_GAP' => $cfg->exists('Scheduler', 'MailAccAttemptsGap') ? $cfg->val('Scheduler', 'MailAccAttemptsGap') : &configIssue('Scheduler', 'MailAccAttemptsGap'),
			'ldap_host' => $cfg->exists('LDAP', 'Host') ? $cfg->val('LDAP', 'Host') : &configIssue('LDAP', 'Host'),
			'ldap_dn' => $cfg->exists('LDAP', 'DN') ? $cfg->val('LDAP', 'DN') : &configIssue('LDAP', 'DN'),
			'ldap_basedn' => $cfg->exists('LDAP', 'BaseDn') ? $cfg->val('LDAP', 'BaseDn') : &configIssue('LDAP', 'BaseDn'),
			'ldap_groupdn' => $cfg->exists('LDAP', 'GroupDn') ? $cfg->val('LDAP', 'GroupDn') : &configIssue('LDAP', 'GroupDn'),
			'ldap_pwd' => $cfg->exists('LDAP', 'Pwd') ? $cfg->val('LDAP', 'Pwd') : &configIssue('LDAP', 'Pwd'),
			'ldap_exppolicy' => $cfg->exists('LDAP', 'UidExpirationGap') ? $cfg->val('LDAP', 'UidExpirationGap') : &configIssue('LDAP', 'UidExpirationGap'),
			'mail_host' => $cfg->exists('Mail', 'Host') ? $cfg->val('Mail', 'Host') : &configIssue('Mail', 'Host'),
			'mail_user' => $cfg->exists('Mail', 'User') ? $cfg->val('Mail', 'User') : &configIssue('Mail', 'User'),
			'mail_pwd' => $cfg->exists('Mail', 'Pwd') ? $cfg->val('Mail', 'Pwd') : &configIssue('Mail', 'Pwd'),
			'mailacc_enabled' => $cfg->exists('MailAcc', 'MailAccEnabled') ? $cfg->val('MailAcc', 'MailAccEnabled') : &configIssue('MailAcc', 'MailAccEnabled'),
			'mailacc_host' => $cfg->exists('MailAcc', 'Host') ? $cfg->val('MailAcc', 'Host') : &configIssue('MailAcc', 'Host'),
			'mailacc_user' => $cfg->exists('MailAcc', 'User') ? $cfg->val('MailAcc', 'User') : &configIssue('MailAcc', 'User'),
			'mailacc_pwd' => $cfg->exists('MailAcc', 'Pwd') ? $cfg->val('MailAcc', 'Pwd') : &configIssue('MailAcc', 'Pwd'),
			'mailacc_sh' => $cfg->exists('MailAcc', 'MailShellScriptPath') ? $cfg->val('MailAcc', 'MailShellScriptPath') : &configIssue('MailAcc', 'MailShellScriptPath'),					
			'qontext_enabled' => $cfg->val('Qontext', 'QontextEnabled'),
			'qontext_host' => $cfg->val('Qontext', 'Host'),
			'qontext_user' => $cfg->val('Qontext', 'Admin'),
			'qontext_pwd' => $cfg->val('Qontext', 'Pwd'),
			'sms_host' => $cfg->exists('SMS', 'Host') ? $cfg->val('SMS', 'Host') : &configIssue('SMS', 'Host'),
			'sms_user' => $cfg->exists('SMS', 'ID') ? $cfg->val('SMS', 'ID') : &configIssue('SMS', 'ID'),
			'sms_pwd' => $cfg->exists('SMS', 'Pwd') ? $cfg->val('SMS', 'Pwd') : &configIssue('SMS', 'Pwd'),
			'db' => $cfg->exists('DB', 'DB') ? $cfg->val('DB', 'DB') : &configIssue('DB', 'DB'),
			'link_logout' => $cfg->exists('Paths', 'Logout') ? $cfg->val('Paths', 'Logout') : &configIssue('Paths', 'Logout'),
			'link_main' => $cfg->exists('Paths', 'Main') ? $cfg->val('Paths', 'Main') : &configIssue('Paths', 'Main'),
			'APP_PATH' => $cfg->exists('Paths', 'AppLoc') ? $cfg->val('Paths', 'AppLoc') : &configIssue('Paths', 'AppLoc'),
			'add_access_group' => $cfg->exists('AdminAccess', 'addAccessGroups') ? $cfg->val('AdminAccess', 'addAccessGroups') : &configIssue('AdminAccess', 'addAccessGroups'),
			'delete_access_group' => $cfg->exists('AdminAccess', 'deleteAccessGroups') ? $cfg->val('AdminAccess', 'deleteAccessGroups') : &configIssue('AdminAccess', 'deleteAccessGroups'),
			'events_access_group' => $cfg->exists('AdminAccess', 'eventsAccessGroups') ? $cfg->val('AdminAccess', 'eventsAccessGroups') : &configIssue('AdminAccess', 'eventsAccessGroups'),
			'log_path' => $cfg->exists('Logging', 'LogPath') ? $cfg->val('Logging', 'LogPath') : &configIssue('Logging', 'LogPath'),
			'log_audit' => $cfg->exists('Logging', 'EnableAuditLog') ? $cfg->val('Logging', 'EnableAuditLog') : &configIssue('Logging', 'EnableAuditLog'),
			'log_error' => $cfg->exists('Logging', 'EnableErrorLog') ? $cfg->val('Logging', 'EnableErrorLog') : &configIssue('Logging', 'EnableErrorLog'),
			'log_debug' => $cfg->exists('Logging', 'EnableDebugLog') ? $cfg->val('Logging', 'EnableDebugLog') : &configIssue('Logging', 'EnableDebugLog'),
			'log_events_display_count' => $cfg->exists('Logging', 'EventsDisplayLogCount') ? $cfg->val('Logging', 'EventsDisplayLogCount') : &configIssue('Logging', 'EventsDisplayLogCount'),
			'NTFY_ERROR_TO' => $cfg->exists('Notifications', 'ErrorTo') ? $cfg->val('Notifications', 'ErrorTo') : &configIssue('Notifications', 'ErrorTo'),
			'NTFY_ERROR_CC' => $cfg->exists('Notifications', 'ErrorCc') ? $cfg->val('Notifications', 'ErrorCc') : &configIssue('Notifications', 'ErrorCc'),
			'NTFY_ERROR_FROM' => $cfg->exists('Notifications', 'ErrorFrom') ? $cfg->val('Notifications', 'ErrorFrom') : &configIssue('Notifications', 'ErrorFrom'),
			'NTFY_WELCOME_HR_NAME' => $cfg->exists('Notifications', 'WelcomeHRName') ? $cfg->val('Notifications', 'WelcomeHRName') : &configIssue('Notifications', 'WelcomeHRName'),
			'NTFY_WELCOME_CC' => $cfg->exists('Notifications', 'WelcomeCc') ? $cfg->val('Notifications', 'WelcomeCc') : &configIssue('Notifications', 'WelcomeCc'),
			'NTFY_WELCOME_FROM' => $cfg->exists('Notifications', 'WelcomeFrom') ? $cfg->val('Notifications', 'WelcomeFrom') : &configIssue('Notifications', 'WelcomeFrom'),
			'NTFY_LDAP_OP_TO' => $cfg->exists('Notifications', 'LDAPOpStatusTo') ? $cfg->val('Notifications', 'LDAPOpStatusTo') : &configIssue('Notifications', 'LDAPOpStatusTo'),
			'NTFY_LDAP_OP_CC' => $cfg->exists('Notifications', 'LDAPOpStatusCc') ? $cfg->val('Notifications', 'LDAPOpStatusCc') : &configIssue('Notifications', 'LDAPOpStatusCc'),
			'NTFY_LDAP_OP_FROM' => $cfg->exists('Notifications', 'LDAPOpStatusFrom') ? $cfg->val('Notifications', 'LDAPOpStatusFrom') : &configIssue('Notifications', 'LDAPOpStatusFrom'),
			'NTFY_QONTEXT_OP_TO' => $cfg->exists('Notifications', 'QontextOpStatusTo') ? $cfg->val('Notifications', 'QontextOpStatusTo') : &configIssue('Notifications', 'QontextOpStatusTo'),
			'NTFY_QONTEXT_OP_CC' => $cfg->exists('Notifications', 'QontextOpStatusCc') ? $cfg->val('Notifications', 'QontextOpStatusCc') : &configIssue('Notifications', 'QontextOpStatusCc'),
			'NTFY_QONTEXT_OP_FROM' => $cfg->exists('Notifications', 'QontextOpStatusFrom') ? $cfg->val('Notifications', 'QontextOpStatusFrom') : &configIssue('Notifications', 'QontextOpStatusFrom'),
	);
	return %pconfig;
}

sub configIssue {
	my ($section, $parameter) = @_;
	die "No setting found [$section] $parameter";
}

#use strict;
use UsrMgmTl::PLDAP;
use UsrMgmTl::PLog;
use UsrMgmTl::PEmail;
use UsrMgmTl::PTemplate;
use UsrMgmTl::Qontext;
use UsrMgmTl::PDBI;
use UsrMgmTl::PMailAcc;

1;
