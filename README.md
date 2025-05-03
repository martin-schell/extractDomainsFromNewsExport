# extractDomainsFromNewsExport

Script to transfer the domains from the _Nextcloud News_ Export to a file.

## Usage

```sh
Usage: ./domains2ips.sh
-i, --input <file>  Read file with domains, separated by newline
-h, --help          Print usage
```

## Input

This script expects an OPML file with URLs as value for tag `xmlUrl`.

```xml
<?xml version="1.0" encoding="UTF-8"?>
<opml version="2.0">
  <head>
    <title>Subscriptions</title>
  </head>
  <body>
    <outline title="Podcasts" text="Podcasts">
      <outline title="BSI RSS-Newsfeed Podcast &quot;Ins Internet - mit Sicherheit!&quot;" text="BSI RSS-Newsfeed Podcast &quot;Ins Internet - mit Sicherheit!&quot;" type="rss" xmlUrl="https://www.bsi.bund.de/SiteGlobals/Functions/RSSFeed/RSSNewsfeed/RSSNewsfeed_Podcast_Update_verfuegbar.xml" htmlUrl="https://www.bsi.bund.de"/>
      <outline title="Breach FM - der Infosec Podcast" text="Breach FM - der Infosec Podcast" type="rss" xmlUrl="https://feeds.transistor.fm/breach-fm-der-infosec-podcast" htmlUrl=""/>
    </outline>
    <outline title="Auslegungssache – der c't-Datenschutz-Podcast" text="Auslegungssache – der c't-Datenschutz-Podcast" type="rss" xmlUrl="https://ct-auslegungssache.podigee.io/feed/mp3" htmlUrl="https://heise.de/-4571821"/>
    <outline title="Blog on KittenLabs" text="Blog on KittenLabs" type="rss" xmlUrl="https://kittenlabs.de/blog/index.xml" htmlUrl="https://kittenlabs.de/blog/"/>
  </body>
</opml>
```

## Output

This script generates two files:

**extractDomainsFromNewsExport.out**

```sh
  www.bsi.bund.de
  feeds.transistor.fm
  ct-auslegungssache.podigee.io
  kittenlabs.de
```

**extractDomainsFromNewsExport.log**

```
2025-05-03 13:33:42 [DEBUG] Add www.bsi.bund.de
2025-05-03 13:33:42 [DEBUG] Add feeds.transistor.fm
2025-05-03 13:33:42 [DEBUG] Add ct-auslegungssache.podigee.io
2025-05-03 13:33:42 [DEBUG] Add kittenlabs.de
```

## Further Details

Extract only the domains from file by using a regular expression with POSIX syntax:

1. Extract tag-value of `xmlUrl` from file (1st command)
2. Remove tag (1st pipe)
3. Remove schema (2nd pipe)

```sh
grep -o 'xmlUrl="https\{0,1\}://[^/"]*' $IN_FILE | sed 's/xmlUrl="//' | sed 's|https\{0,1\}://||'
```

**Output of 1st command**

```sh
xmlUrl="https://www.bsi.bund.de
xmlUrl="https://feeds.transistor.fm
xmlUrl="https://ct-auslegungssache.podigee.io
xmlUrl="https://kittenlabs.de
```

**Output with 2nd pipe**

```sh
https://www.bsi.bund.de
https://feeds.transistor.fm
https://ct-auslegungssache.podigee.io
https://kittenlabs.de
```

**Final output**: see above

### Nice to know - Regular expression styles POSIX vs. PCRE with `grep`

The following patterns result in the same output.

PCRE: `grep -oP 'xmlUrl="https?:\/\/(?:www\.)?\K[^\/"]+' "$EXPORTFILE"`
POSIX: `grep -o 'xmlUrl="https\{0,1\}://[^/"]*' export_test.opml | sed 's/xmlUrl="//' | sed 's|https\{0,1\}://||'`

`grep -P` interpretes the pattern as PCRE (see [pcre.org](https://www.pcre.org/)).

The PCRE syntax can only be used if GNU `grep` is installed (see [BSD grep](https://wiki.freebsd.org/KyleEvans/BSDgrep)).
The POSIX syntax is also supported by systems which lack support for PCRE.

To check your `grep` version, run `grep -V`. 

```sh
user@server:~$ grep -V
grep (GNU grep) 3.11
Copyright © 2023 Free Software Foundation, Inc.
Lizenz GPLv3+: GNU GPL Version 3 oder neuer <https://gnu.org/licenses/gpl.html>.
Dies ist freie Software: Sie können sie ändern und weitergeben.
Es gibt keinerlei Garantien, soweit gesetzlich zulässig.

Geschrieben von Mike Haertel und anderen; siehe
<https://git.savannah.gnu.org/cgit/grep.git/tree/AUTHORS>.

grep -P verwendet PCRE2 10.42 2022-12-11
```
