#!/bin/bash

domain=$1
if [ -z "$domain" ]
then
    echo "Please specify a FQDN. eg:('google.com')"
    exit 1
elif [[ "$domain" =~ ^http://* ]] || [[ "$domain" =~ ^https://* ]]
then
    echo "Please specify a FQDN without Protocol and Symbols. eg:('google.com')"
    exit 1
elif grep -oP '^((?!-)[A-Za-z0-9-]{1,63}(?<!-)\.)+[A-Za-z]{2,6}$' <<< "$domain" >/dev/null 2>&1;
then
#dig +trace domain
echo "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
echo "Dig +trace result for $domain"
echo "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
dig +nocmd $domain a +noall +answer >> ~/digtrace
dig +nocmd $domain ns +noall +answer >> ~/digtrace
dig +trace @8.8.8.8 $domain | grep "$domain." | grep -vE 'RRSIG|;' >> ~/digtrace
cat ~/digtrace | sort | sort -u -k 5 && rm -f ~/digtrace

#MX Record
echo "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
echo  "MX Record Result for $domain"
echo "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
#dig +nocmd $domain txt +noall +answer
dig +nocmd $domain mx +noall +answer | sort -k 5

#TXT Record
echo "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
echo  "TXT Record Resutl for $domain"
echo "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
#dig txt $domain | grep ^"$domain" | grep TXT
dig +nocmd $domain txt +noall +answer

IP=`dig +nocmd $domain a +noall +answer | grep ^"$domain" | grep A | awk {'print $5'} | head -n1`
#IP=`dig $domain | grep ^"$domain" | grep A | awk {'print $5'} | head -n1`
#host for IP
echo "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
echo  "PTR record for $IP"
echo "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
#host $IP | awk {'print $5'}
dig -x $IP +noall +answer | grep -vE ^";|^$"

MX=`dig +nocmd $domain mx +noall +answer | grep ^"$domain" | grep MX | awk {'print $6'} | rev | cut -c2- | rev | head -n1`
#MX=`dig mx $domain | grep ^"$domain" | grep MX | awk {'print $6'} | rev | cut -c2- | rev | head -n1`
#MX Trying IP Resutl
echo "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
echo  "Telnet trying connect IP Result for the $MX"
echo "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
echo "IP: `timeout 1 telnet $MX 587 > ~/Try; timeout 1 telnet $MX 25 >> ~/Try; cat ~/Try | grep -v -e '^$'| grep Trying | head -n1 | awk {'print $2'} | rev | cut -c4- |rev; rm -f ~/Try`"

#Netcatch Result for MX 25 & 587
echo "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
echo  "Telnet Result for IP: $IP && MX: $MX >> 25 & 587"
echo "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
echo "IP: `timeout 3 nc $IP 587 > ~/rre; timeout 1 nc $IP 25 >> ~/rre; cat ~/rre | grep -v -e '^$'| head -n1; rm -f ~/rre`"
echo "          ------"
echo "MX: `timeout 3 nc $MX 587 > ~/rre; timeout 1 nc $MX 25 >> ~/rre; cat ~/rre | grep -v -e '^$'| head -n1; rm -f ~/rre`"

#WHOIS Result for Domain
echo "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
echo  "WHOIS Result for the Domain $domain"
echo "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
whois $domain | grep -E "Registrar:|Registry Expiry Date:|Registrar URL:|Name Server:|Expiration Date:|Status:|URL:"
echo "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
else
echo "Please enter a valid FQDN. eg:('google.com')"
fi