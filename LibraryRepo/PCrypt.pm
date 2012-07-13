#!/usr/bin/perl

package UsrMgmTl::PCrypt;

my %lconfig = &UsrMgmTl::Init::readConfig();

sub encode {
	my ($str) = @_;
	my $key = $lconfig{SALT};
	my $enc_str = '';
	for my $char (split //, $str){
		my $decode = chop $key;
		$enc_str .= chr(ord($char) ^ ord($decode));
		$key = $decode . $key;
	}
	return $enc_str;
}

1;
