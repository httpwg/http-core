#!/bin/sh
# refresh file inclusions

expand() {

  cat $1 | awk ' 
  BEGIN {
    includefile = "";
  }
  
  # start include
  /^<\?BEGININC .* \?>$/ {
    print
    includefile = $2
    while (getline <includefile > 0) {
      print
    }
  }
  
  # end include
  /^<\?ENDINC .* \?>$/ {
    if ($2 != includefile) {
      printf ("unexpected ENDINC, got %s but expected %s\n", $2, includefile) >> /dev/stderr
    }
    includefile = "";
  }
  
  #default
  {
    if (includefile == "") {
      print
    }
  }' > $$
  
  # check for changes
  
  cmp -s $1 $$ || ( cp $$ $1 ; echo $1 updated )
  
  rm -f $$
}

[ $# -ne 0 ] || echo "refresh-inclusions.sh file..." >&2 ; exit 2

for i in $*
do
  expand $i
done

