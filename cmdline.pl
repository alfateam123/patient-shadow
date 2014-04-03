#!/usr/bin/env perl

use CGI;
use feature 'say';

use akatsuki;

akatsuki::personalizedFeed($ARGV[0]);