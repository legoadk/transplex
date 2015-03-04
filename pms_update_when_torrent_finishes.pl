#!/usr/bin/perl
use strict;
use warnings;
our $storage = '/srv/data/Media';
our $logfile = "/var/lib/transmission/transmission-pms-update.log";
#our $plex_media_scanner = '/usr/lib/plexmediaserver/Plex Media Scanner';
our $plex_media_scanner = '/usr/local/bin/pmscan';
our $torrent_dir = $ENV{'TR_TORRENT_DIR'};
our $user = $ENV{'USER'};
#  1: Movies
#  2: TV Shows
#  3: Documentaries
#  4: Home Movies
#  5: Sports

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
