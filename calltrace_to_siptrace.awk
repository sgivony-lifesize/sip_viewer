#!/bin/awk -f

BEGIN { 
  FS="|" 
  RS="\n20"
}

/libdylogicsip.SIPManager/{
  if ( $6 == "REQ" || $6 == "RES" ) {
    split($15, content, " ");
	DIR = "IN"
	if (content[4] == "TX") {
	  DIR = "OUT"
	}
	curdate = sprintf("20%s", $1)
	gsub("\\-", "/", curdate)
	gsub(",", ".", curdate)
	
	message = substr($0, index($0, "\n"))
    
    # filter options and publish
    skip = 0
    
    where = match(message, "CSeq: [0-9]* PUBLISH")
    if (where != 0) skip = 1
    where = match(message, "CSeq: [0-9]* REGISTER")
    if (where != 0) skip = 0
    where = match(message, "Skipping mandatory switch")
    if (where != 0) skip = 1
    where = match($12, "sip:\"[0-9]*,")
    if (where != 0) skip = 1
    where = match($12, "sip:[0-9]* $")
    if (where != 0) skip = 1
    #where = match(message, "CSeq: [0-9]* OPTIONS") 
    #if (where != 0) skip = 1
    
    #where1 = match(message, "sips:3170538@lifesizecloud.com")
    #where2 = match(message, "sips:3170538@lifesizecloud.com")
    #if (where1 == 0 && where2 == 0) {
    #    skip = 1
    #}

    if (skip == 0) {
        printf "[%s] %s %s --> %s\n", curdate, DIR, content[1], content[3]
        printf "%s\n-----------------------\n", message
    }
  }
}
