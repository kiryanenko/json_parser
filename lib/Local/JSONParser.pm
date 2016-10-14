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
#p parse_json('{ "key1": "string value", "key2": -3.1415, "key3": ["nested array"], "key4": { "nested": "object" } }');

# Функция получает ссылку на строку и парсит первую найденную структуру 
# и затирает строку с ней
sub parse_first_struct {
	my $source = shift;
	#say "parse_json: $$source";
	
	if ( $$source =~ s/^\s*"(.*?)(?<!\\)"//s ) {
		my $str = $1;
		
		$str =~ s/\\t/\t/g;
		$str =~ s/\\n/\n/g;		
		$str =~ s/\\"/\"/g;
		
		$str =~ s/\\u(\d+)/chr(hex($1))/ge;
		
		return $str;
	}
	elsif ( $$source =~ s/^\s*([+-]?\d+(\.\d+)?(e[\+-]?\d+)?)//s ) {
		return 0 + $1;
	}
	elsif ( $$source =~ s/^\s*\[//s ) {
		my @res;			
		while ( $$source !~ s/^\s*\]//s ) {
			push @res, parse_first_struct($source);
			if ( $$source =~ s/^\s*,//s ) {				
				die 'В массиве "висящая" запятая' if $$source =~ /^\s*\]/s;
			} else {
				die "В массиве перед $$source пропущена запятая" 
					unless $$source =~ /^\s*\]/s
			}
		}
		return \@res;
	}
	elsif ( $$source =~ s/^\s*\{//s ) {
		my %res;
		while ( $$source !~ s/^\s*\}//s ) {
			if ($$source =~ s/^\s*"(\w+)"\s*://s) {
				my $key = $1;
				$res{$key} = parse_first_struct($source);
				if ( $$source =~ s/^\s*,//s ) {				
					die 'В объекте "висящая" запятая' if $$source =~ /^\s*\}/s;
				} else {
					die "В объекте перед $$source пропущена запятая" 
						unless $$source =~ /^\s*\}/s
				}
			} else {
				die "В объекте не валидный элемент $$source"
			}
		}
		return \%res;
	}
	else { 
		die "Не валидная структура $$source"; 
	}
}

sub parse_json {
	my $source = shift;
	
	use JSON::XS;	
	#return JSON::XS->new->utf8->decode($source);
	
	return parse_first_struct(\$source);
}

1;
