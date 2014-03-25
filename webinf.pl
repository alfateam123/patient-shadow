#!/usr/bin/env perl

use CGI;
use feature 'say';
#use JSON;

use akatsuki;

#print "Content-type: text/plain\n\n";
my $cgiobj = CGI->new;

print $cgiobj->header(-charset=>'utf-8');#('application/json');
akatsuki::personalizedFeed($cgiobj->param("username"));
$cgiobj->redirect($cgiobj->param("username")."rss");
