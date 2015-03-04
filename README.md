# TransPlex
A simple set of scripts for triggering Plex server refreshes when a torrent in Transmission finishes.
Designed to work where Plex Media Server is running on the same Linux system as Transmission Daemon.

## Installation/Configuration of `pmscan`
`pmscan` is a simple utility that does nothing more than call the standard Plex Media Scanner after establishing an imitation Plex environment.
The entire contents of the script is essentially exported variables. **These may be different on various installations of Plex,** so what follows are a few steps that can help you discover what the contents of `pmscan` should be on *your* system.
1. Load up Plex Web in your web browser and browse to a section containing media.
2. Prepare this command in the shell:
```sh
$ sudo cat /proc/`pidof Plex\ Media\ Scanner`/environ
```
3. Click the "Refresh" button in the Plex Web interface and quickly switch back to your shell and run the command.

This should print the environment of the currently running `Plex Media Scanner`, albeit in one line, but this is the basis for a custom version of `pmscan`. Seperate the string into lines, add `export` before each, and include the final call to the `Plex Media Scanner` binary as in the provided version of `pmscan` (correcting the location if necessary). 

Once you have either confirmed that the included script is functional, or created your own with the guide above, it can be copied to `/usr/local/bin`:
```sh
$ chmod +x pmscan && sudo cp pmscan /usr/local/bin
```

## Configuring the Transmission Script
Now that you have a working pmscan, you can use it to further customize the script that Transmission calls. This script aims to be rather efficient, only calling for a refresh if the downloaded data of the torrent that triggered the script is actually in a folder indexed by Plex; even going so far as to pick specifically which section it refreshes. These rules, however, are up to you to define. 
Before going much further it is important to note that in most Transmission Daemon installations, the daemon runs under the `transmission` user, with a home of `/var/lib/transmission`. Similarly, the Plex Media Server usually runs as `plex`, with a home of `/var/lib/plex`. **Just like the Plex configuration above, this is not always the case.** Certain permissions-related issues can arise, and how to solve them depends on the situation. At the very least, you'll need to add this line to `/etc/sudoers` for the script to work:
```sudoers
transmission ALL = (plex) NOPASSWD: /usr/local/bin/pmscan
```
Whether to accept this modification—and the security caveats it may imply—is up to the reader.
A key part of configuring the script for your system is discovering the internal Plex section IDs for your Plex Media Server. There are two ways to do this:

- By looking at the number at the end of the URL (after the last forward-slash) when you click on a section in Plex Web.
- By passing the `--list` argument to `pmscan`.

`pmscan` must always be run as the `plex` user otherwise interesting breakages and errors could occur; therefore, we can obtain a list of the Plex setions using this command:
```sh
$ sudo -u plex pmscan --list
  3: Movies
  2: TV Shows
```

Using this information, the `%sections` hash in the script can be updated. Pay close attention to the `$storage` variable. This is considered the "root" of your media library storage. My media is organized such that the section name that Plex uses is also the name of the subdirectory beneath `$storage` where the corresponding media is stored; you may have a different setup, therefore the script may very well need to be modified to work with a different pattern.
You should also update the `$logfile` variable should transmission's home directory be different, or if you wish the logfile to be somewhere else.

Once you have an adequately-modified script, you can place it inside the home folder of the `transmission` user, in this case `/var/lib/transmission`:
```sh
$ sudo cp pms_update_when_torrent_finishes.pl /var/lib/transmission/
```

## Triggering the Script with Transmission
There wasn't much documentation on this feature of Transmission, but after some deep searches I found that transmission natively supports calling a script on completion.
(Adjust your hostname, port, user/pass as required.)
```sh
$ transmission-remote localhost:9091 --auth [user]:[pass] --torrent-done-script /var/lib/transmission/pms_update_when_torrent_finishes.pl
```

Now, download something to a directory that Plex is indexing, and see if it works.