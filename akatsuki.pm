#!/usr/bin/perl
package akatsuki;

use utf8;
use strict;
use warnings;
use feature 'say';

use JSON;
use XML::FeedPP;
use Data::Dumper;

use akatsuki::nyaa;

my $DEBUG = 0;

sub buildUrlList {
	my $sources = shift;
	my @list;
	foreach my $source (keys %{$sources}){
		@list = akatsuki::nyaa::buildUrlList $sources->{'nyaa'}->{filter} if $source eq 'nyaa';
	}
	@list;
}

sub buildRSSLinks{
	my $sources = shift;
	say '$sources = '.Dumper($sources) if $DEBUG;
	my @links = ();
	foreach my $url (buildUrlList $sources){
		push @links, {link => $url, limit => 5};
	}
	\@links;
}

sub getTorrentsFrom{
	#source: a link to a RSS feed
	my $source = shift;
	say Dumper $source if $DEBUG;
	#we should retrieve 5 (or user-defined number) post and extract download links
	my @torrents;
	foreach my $source_info ( @{ buildRSSLinks $source }){
		say Dumper $source_info if $DEBUG;
		my $feed = XML::FeedPP->new($source_info->{"link"});
		$feed->limit_item($source_info->{"limit"});
		foreach my $post ($feed->get_item())
		{
			push @torrents, {"title" => $post->title(),
			                 "link" => $post->link(),
			                 "pubDate" => $post->pubDate()
			                };
		}
	}
	\@torrents;
}

sub buildRSSItems {
	#torrents: ref to list of {"link"=>torrent download link, "title"=>title of the post, etc}
	my $torrents = shift;
	#we should generate the RSS posts for the feed.
	my @items; 
	my $gen_feed = XML::FeedPP::RDF->new();
	foreach my $torrent (@{$torrents})
	{
		my $newpost = $gen_feed->add_item($torrent->{"link"});
		$newpost->title($torrent->{"title"});
		$newpost->pubDate($torrent->{"pubDate"});
		say "pubDate: ".Dumper($torrent->{"pubDate"});
		push @items, $newpost;
	}
	@items; #$gen_feed->to_string ;
}

sub retrieveUserConfig {
    my $username = shift; 
    my $config;
    { local $/ = undef; local *FILE; open FILE, "<", "people.json"; $config = <FILE>; close FILE }
    $config = decode_json $config;
    ( grep {say Dumper $_ if $DEBUG; $_->{"user"} eq $username} @{$config->{"users"}} )[0];
}


sub personalizedFeed {
	my $conf = retrieveUserConfig $_[0];
	#say "retrieving info for ".$_[0]."...";
	Dumper($conf);
	if ($conf)
	{	
		my @muh_feed_posts;
		for my $source ($conf->{"sources"})
	    {
	    	Dumper($source);
	    	my $torrents = getTorrentsFrom $source;
	    	push @muh_feed_posts, (buildRSSItems $torrents);
		}
		my $gen_feed = XML::FeedPP::RDF->new();
		$gen_feed->title($_[0]."'s Akatsuki feed");
		$gen_feed->link("http://github.com/alfateam123/patient-shadow");
		map { $gen_feed->add_item($_); $_ } @muh_feed_posts;
		$gen_feed->sort_item(); #order by publish date
		$gen_feed->to_file($_[0].".rss");
		say $gen_feed->to_string if $DEBUG;
	}
	else
	{
		say "fuck you!";
	}
}

1;