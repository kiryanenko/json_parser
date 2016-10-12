package Local::JSONParser;


use 5.010;
use strict;
use warnings;
use base qw(Exporter);
our @EXPORT_OK = qw( parse_json );
our @EXPORT = qw( parse_json );

BEGIN{
	if ($] < 5.018) {
		package experimental;
		use warnings::register;
	}
}
no warnings 'experimental';

use DDP;
p parse_json('[{"sss" : 12312,"ddsss" : "hhhh"},]');


sub parse_json {
	my $source = shift;
	say "parse_json: $source";
	my $res;
	
	given ($source) {
		when (/^\s*"(.*)"\s*$/m) {
			return $1;
		}
		when (/^\s*(\d+(\.\d+)?(e[\+-]?\d+)?)\s*$/m) {
			return 0 + $1;
		}
		when (/^\s*\{(.*)\}\s*$/m) {
			my %res;
			my $content = $1;
			my @arr = split ',', $content;
			for (@arr) {
				if (/^\s*"(\w+)"\s*:\s*(.+)\s*$/m) {
					$res{$1} = parse_json($2);
				} else {
					die "Не валидный элемент $_";
				}
			}
			return \%res;
		}
		when (/^\s*\[(.*)\]\s*$/m) {
			my @res;
			my $content = $1;
			my @arr = split ',', $content;
			for (@arr) {
				push @res, parse_json($_);
			}
			return \@res;
		}
		default { die "Не валидный элемент $_"; }
	}
	
	
	#use JSON::XS;	
	# return JSON::XS->new->utf8->decode($source);
	#return {};
}

1;
