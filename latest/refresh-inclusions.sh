#!/bin/sh
# refresh file inclusions

expand() {

  cat $1 | awk ' 
  BEGIN {
    includefile = "";
  }
  
  # start include
  /^<!-- BEGININC .* -->$/ {
    print
    includefile = $3
    while (getline <includefile > 0) {
      print
    }
  }
  
  # end include
  /^<!-- ENDINC .* -->$/ {
    if ($3 != includefile) {
      printf ("unexpected ENDINC, got %s but expected %s\n", $3, includefile) >> /dev/stderr
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

for i in $*
do
  expand $i
done

