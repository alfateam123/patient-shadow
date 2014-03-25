#!/usr/bin/perl
package akatsuki;

use utf8;
use strict;
use warnings;
use feature 'say';

use JSON;
use XML::FeedPP;
#use Data::Dumper;


sub getTorrentsFrom{
	#source: a link to a RSS feed
	my $source = shift;
	#we should retrieve 5 (or user-defined number) post and extract download links
	my $feed = XML::FeedPP->new($source);
	my @torrents;
	my ($counter, $limit) = (0,5);
	foreach my $post ($feed->get_item())
	{
		#say $limit.$counter;
		last if $limit == $counter;
		push @torrents, {"title" => $post->title(), "link" => $post->link()};
		$counter++;
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
		push @items, $newpost;
	}
	@items; #$gen_feed->to_string ;
}

sub retrieveUserConfig {
    my $username = shift; 
    my $config;
    { local $/ = undef; local *FILE; open FILE, "<", "people.json"; $config = <FILE>; close FILE }
    $config = decode_json $config;
    ( grep {$_->{"user"} eq $username} @{$config} )[0];
}


sub personalizedFeed {
	my $conf = retrieveUserConfig $_[0];
	#say "retrieving info for ".$_[0]."...";
	if ($conf)
	{	
		my @muh_feed_posts;
		for my $source (@{$conf->{"sources"}})
	    {
	    	my $torrents = getTorrentsFrom $source;
	    	push @muh_feed_posts, (buildRSSItems $torrents);
		}
		my $gen_feed = XML::FeedPP::RDF->new();
		$gen_feed->title("Akatsuki strikes again");
		$gen_feed->link("");
		map { $gen_feed->add_item($_); $_ } @muh_feed_posts;
		$gen_feed->to_file($_[0].".rss");
		say $gen_feed->to_string;
	}
	else
	{
		say "fuck you!";
	}
}

__END__