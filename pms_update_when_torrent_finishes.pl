#!/usr/bin/perl
use strict;
use warnings;
our $logfile = "/var/lib/transmission/transmission-pms-update.log";
our $plex_media_scanner = '/usr/local/bin/pmscan';
our $torrent_dir = $ENV{'TR_TORRENT_DIR'};
our $user = $ENV{'USER'};

# the root of your media library
our $storage = '/srv/data/Media';

# the sections as numbered by Plex. These are also subdirectories of $storage.
#  3: Movies
#  2: TV Shows
our %sections = (
	3 => 'Movies',
	2 => 'TV Shows'
);

open(LOG,'>>',$logfile) or die $!;
print LOG localtime()." env: $torrent_dir\n";
for my $number ( keys %sections ) {
	my $name = $sections{$number};
		
	if ( $torrent_dir =~ m:^$storage/$name.*: ) {
		print LOG localtime()." matched to $name!\n";
		print LOG localtime()." $name: Scanning...\n";
		my @args = ('sudo', '-u', 'plex', $plex_media_scanner, '-c', $number, '-s'); 
		system (@args) == 0
			or print LOG localtime()." system @args failed: $?\n";
		print LOG localtime()." $name: Updating metadata...\n";
		@args = ('sudo', '-u', 'plex', $plex_media_scanner, '-c', $number, '-r'); 
		system (@args) == 0
			or print LOG localtime()." system @args failed: $?\n";
		print LOG localtime()." $name: Refresh Complete.\n"
	}
}
close LOG;
