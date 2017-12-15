#!/bin/bash

trace_file=$1

SCRIPTPATH=$( cd $(dirname $0) ; pwd -P )

check_dependencies ()
{
    dpkg -s gawk > /dev/null 2>&1 || error_exit "gawk package is missing. Please install it first (Linux: \"sudo apt-get install gawk\")"
}

usage ()
{
    echo "Usage: `basename $0` <CallTrace>"
    exit 1
}

check_dependencies

[[ -z $trace_file ]] && usage
[[ ! -f $trace_file ]] && usage

trace=${trace_file:0:-4}   # remove extension
siptrace_file=$trace.sipv.siptrace.log
output_file=$trace.sipv.output.log
output_no_sip_file=$trace.sipv.output_no_msg.log
css_nodes_map=$SCRIPTPATH/css_nodes.csv

LC_ALL=C gawk -f $SCRIPTPATH/calltrace_to_siptrace.awk $trace_file > $siptrace_file
java -jar $SCRIPTPATH/sip-viewer-1.9.2-jar-with-dependencies.jar -io      $siptrace_file > $output_file
java -jar $SCRIPTPATH/sip-viewer-1.9.2-jar-with-dependencies.jar -io -hsl $siptrace_file > $output_no_sip_file

# Replacing nodes IPs with names according to CSS nodes table
if [[ -f $css_nodes_map ]]; then
    while read p; do

        # fetching IPs and name
        ip_ex=`echo $p | awk -F',' '{print $4}'`
        ip_in=`echo $p | awk -F',' '{print $5}'`
        name=`echo $p | awk -F',' '{print $3}'`

        # padding with spaces
        let x_ex=${#ip_ex}-${#name}
        let x_in=${#ip_in}-${#name}
        line_ex=$(printf "%*s%s" $x_ex '' "$name")
        line_in=$(printf "%*s%s" $x_in '' "$name")
  
        # replacing IP addresses with name
        sed -i -e "s/$ip_ex/$line_ex/g" $output_no_sip_file
        sed -i -e "s/$ip_in/$line_in/g" $output_no_sip_file

    done < $css_nodes_map
else
    echo "Couldn't replace IPs with nodes names. Map file $css_nodes_map is missing"
fi

