#!/usr/bin/awk -f

# waitfordoctype:
# 0: wait for line starting with DOCTYPE and eat empty lines
# 1: wait for line starting with <html
# 2: afterwards

BEGIN {
  waitfordoctype = 0;
}

/<!DOCTYPE .*/ {
  if (waitfordoctype == 0) {
    waitfordoctype = 1
  }
}

/<html.*/ {
  if (waitfordoctype == 1) {
    waitfordoctype = 2
    printf("<!DOCTYPE html>\n")
  }
  else {
    print
  }
}

{
  if (waitfordoctype == 0 && $0 != "") {
    print
  }
  else if (waitfordoctype == 2) {
    print
  }
}