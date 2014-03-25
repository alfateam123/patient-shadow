#!/usr/bin/perl
use utf8;
use strict;
use warnings;
use feature 'say';

use JSON;
use XML::FeedPP;

sub getTorrentsFrom{
	#source: a link to a RSS feed
	my $source = shift;
	#we should retrieve 5 (or user-defined number) post and extract download links
	return ["list", "of", ".torrent", "links"]; 
}

sub buildRSSItems {
	#torrents: ref to list of {"link"=>torrent download link, "title"=>title of the post, etc}
	my $torrents = shift;
	#we should generate the RSS posts for the feed.
	return "RSS Items";
}

sub retrieve_user_config {
    my $username = shift; 
    #it will be replaced by a search in a JSON file
	(
    grep {$_->{"user"} eq $username} (
	  {'user'=>'alfateam123', 'sources'=>['1', '2', '3']},
	  {'user'=>'RoxasShadowRS', 'sources'=>['lel', 'lal', 'lol']}
	  )
	)[0];
}

sub personalized_feed {
	my $conf = retrieve_user_config $_[0];
	say "retrieving info for ".$_[0]."...";
	if ($conf)
	{	
		for my $source (@{$conf->{"sources"}})
	    {
	    	$torrents = getTorrentsFrom $source;
	    	say (buildRSSItems $torrents);
		}
	}
	else
	{
		say "fuck you!";
	}
}

personalized_feed $ARGV[0];