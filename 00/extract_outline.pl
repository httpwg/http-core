#!/usr/bin/perl
#
# read each line from each HTML file on command-line
# looking for table of contents.  print only the ToC
# with substitutions for an external outline jump table.

$intoc = 0;
$title = "";

while (<>) {
    if ($intoc) {
        s/<a href="\#/<a href="$ARGV\#/g;
        print;
        if (m:^      </ul>:o) {
            $intoc = 0;
        }
    }
    else {
        if (/^      <p class="title">([^<]*)</o) {
            $title = $1;
        }
        elsif (/<a href="#rfc\.toc">Table of Contents/o) {
            print "\n<h2><a href=\"$ARGV\">$title</a></h2>\n";
            $intoc = 1;
            $title = "";
        }
    }
}
