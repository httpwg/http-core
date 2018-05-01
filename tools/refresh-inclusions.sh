#!/bin/sh
# Refresh file inclusions based on XML processing instructions
# 
# Copyright (c) 2006-2016, Julian Reschke (julian.reschke@greenbytes.de)
# All rights reserved.
# 
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are met:
# 
# * Redistributions of source code must retain the above copyright notice,
#   this list of conditions and the following disclaimer.
# * Redistributions in binary form must reproduce the above copyright notice,
#   this list of conditions and the following disclaimer in the documentation
#   and/or other materials provided with the distribution.
# * Neither the name of Julian Reschke nor the names of its contributors
#   may be used to endorse or promote products derived from this software
#   without specific prior written permission.
# 
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
# AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
# IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
# ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE
# LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
# CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
# SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
# INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
# CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
# ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
# POSSIBILITY OF SUCH DAMAGE.

expand() {

  # remember whether we started with CRLF (assumes that we have dos2unix)
  CRLF=$(dos2unix -ic "$1" 2>/dev/null | tr -d ' ')
  
  cat "$1" | awk ' 

  function filecontents(filename) {
    while (getline < filename > 0) {
      fc[filename] = fc[filename] $0 "\n"
    }
    return fc[filename]
  }

  BEGIN {
    includefile = "";
    includeescapedfile = "";
  }
  
  # start include (verbatim mode)
  /<\?BEGININC .* \?>$/ {
    print
    keyword = "<?BEGININC " 
    extract = match($0, /<\?BEGININC .* \?>$/)
    includefile = substr($0, RSTART + length(keyword),
                    RLENGTH - 3 - length(keyword))
    output = filecontents(includefile)
    printf("%s", output)
  }
  
  # start include (escape-for-XML mode)
  /<\?BEGINESCAPEDINC .* \?>$/ {
    print
    keyword = "<?BEGINESCAPEDINC " 
    extract = match($0, /<\?BEGINESCAPEDINC .* \?>$/)
    includeescapedfile = substr($0, RSTART + length(keyword),
                           RLENGTH - 3 - length(keyword))
    output = filecontents(includeescapedfile)
    # escape ampersand, less-than, and greater-than
    # when part of a CDATA end marker
    gsub(/&/, "\\&amp;", output)
    gsub(/</, "\\&lt;", output)
    gsub(/]]>/, "]]\\&gt;", output)
    printf("%s", output)
  }

  # end include (verbatim mode)
  /^<\?ENDINC .* \?>/ {
    if ($2 != includefile) {
      printf ("unexpected ENDINC, got %s but expected %s\n", $2,
        includefile) >> "/dev/stderr"
    }
    includefile = "";
  }
  
  # end include (escape-for-XML mode)
  /^<\?ENDESCAPEDINC .* \?>/ {
    if ($2 != includeescapedfile) {
      printf ("unexpected ENDESCAPEDINC, got %s but expected %s\n", $2,
        includeescapedfile) >> "/dev/stderr"
    }
    includeescapedfile = "";
  }

  #default
  {
    if (includefile == "" && includeescapedfile == "") {
      print
    }
  }
  
  END {
    if (includefile != "") {
      printf ("missing ENDINC for %s\n",
        includefile) >> "/dev/stderr"
    }
    if (includeescapedfile != "") {
      printf ("missing ENDESCAPEDINC for %s\n",
        includeescapedfile) >> "/dev/stderr"
    }
  }
  
  ' > $$
  
  # restore CRLF if needed
  if [ -n "$CRLF" ]; then
    FNN=$(echo "$1" | tr -d ' ')
    [ "$FNN" = "$CRLF" ] && unix2dos -q $$
  fi
  
  # check for changes
  cmp -s "$1" $$ || (
    cp -v "$1" "$1".ri.bak
    cp $$ "$1"
    echo "$1" updated )
  
  rm -f $$
}

[ $# -ne 0 ] || ( echo "refresh-inclusions.sh file..." >&2 ; exit 2 )

for i in $*
do
  expand $i
done
