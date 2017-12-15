@echo off
cat CallTrace.*.log | gawk -f calltrace_to_siptrace.awk > siptrace.log
java -jar sip-viewer-1.9.2-jar-with-dependencies.jar -io siptrace.log > output.txt
java -jar sip-viewer-1.9.2-jar-with-dependencies.jar -io -hsl siptrace.log > output_no_SIP_log.txt
echo Done.