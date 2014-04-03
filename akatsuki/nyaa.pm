package akatsuki::nyaa;
use strict;
use warnings;

sub buildUrlList{
	map {"http://www.nyaa.se/?page=rss&term=$_"} @{$_[0]}; #@{$queries};
}

1;