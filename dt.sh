#!/bin/bash

function dig_domain () {
#dig +trace domain
echo "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
echo "Dig +trace result of the $domain"
echo "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
dig +nocmd $domain a +noall +answer >> ~/digtrace
dig +nocmd $domain ns +noall +answer >> ~/digtrace
dig +trace @8.8.8.8 $domain | grep "$domain." | grep -vE 'RRSIG|;' >> ~/digtrace
cat ~/digtrace | sort | sort -u -k 5 && rm -f ~/digtrace

#MX Record
echo "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
echo  "MX Record Result of the $domain"
echo "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
#dig +nocmd $domain txt +noall +answer
dig +nocmd $domain mx +noall +answer | sort -k 5

#TXT Record
echo "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
echo  "TXT Record Resutl of the $domain"
echo "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
#dig txt $domain | grep ^"$domain" | grep TXT
dig +nocmd $domain txt +noall +answer

IP=`dig +nocmd $domain a +noall +answer | grep ^"$domain" | grep A | awk {'print $5'} | head -n1`
#IP=`dig $domain | grep ^"$domain" | grep A | awk {'print $5'} | head -n1`
#host for IP
echo "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
echo  "PTR record result of the $IP"
echo "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
#host $IP | awk {'print $5'}
dig -x $IP +noall +answer | grep -vE ^";|^$"

MX=`dig +nocmd $domain mx +noall +answer | grep ^"$domain" | grep MX | awk {'print $6'} | rev | cut -c2- | rev | head -n1`
#MX=`dig mx $domain | grep ^"$domain" | grep MX | awk {'print $6'} | rev | cut -c2- | rev | head -n1`
#MX Trying IP Resutl
echo "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
echo  "Telnet trying to connect that IP Result of the $MX"
echo "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
which telnet >/dev/null 2>&1
if [ $? = 0 ]; then
echo "IP: `timeout 1 telnet $MX 587 > ~/Try; timeout 1 telnet $MX 25 >> ~/Try; cat ~/Try | grep -v -e '^$'| grep Trying | head -n1 | awk {'print $2'} | rev | cut -c4- |rev; rm -f ~/Try`"
else
echo "Please read the README and install telnet package as per your Operating System Repository ie:('yum install telnet')"
fi

#Netcatch Result for MX 25 & 587
echo "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
echo  "Telnet Result of IP: $IP && MX: $MX and checking both 25 & 587"
echo "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
which nc >/dev/null 2>&1
if [ $? = 0 ]; then
echo "IP: `timeout 3 nc $IP 587 > ~/rre; timeout 1 nc $IP 25 >> ~/rre; cat ~/rre | grep -v -e '^$'| head -n1; rm -f ~/rre`"
echo "          ------"
echo "MX: `timeout 3 nc $MX 587 > ~/rre; timeout 1 nc $MX 25 >> ~/rre; cat ~/rre | grep -v -e '^$'| head -n1; rm -f ~/rre`"
else
echo "Please read the README and install nc package as per your Operating System Repository ie:('yum install nc')"
fi

#WHOIS Result for Domain
echo "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
echo  "WHOIS Result of the $domain"
echo "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
which whois >/dev/null 2>&1
if [ $? = 0 ]; then
whois $domain | grep -E "Registrar:|Registry Expiry Date:|Registrar URL:|Name Server:|Expiration Date:|Status:|URL:"
else
echo "Please read the README and install whois package as per your Operating System Repository ie:('yum install whois')"
fi
echo "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
}

domain=$1
if [ -z "$domain" ]
then
        echo "Please specify a FQDN. eg:('google.com')"
        exit 1
elif [[ "$domain" =~ ^http://* ]] || [[ "$domain" =~ ^https://* ]]
then
        domain=$(echo "$1"| cut -d: -f2 | sed 's/[<>/:]//g')
        if grep -oP '^((?!-)[A-Za-z0-9-]{1,63}(?<!-)\.)+[A-Za-z]{2,6}$' <<< "$domain" >/dev/null 2>&1;
        then
            echo "Your domain name look like this: $domain"
            sleep 2
            dig_domain
            exit 1
        else
            echo "Please re-run the script with a valid FQDN without Protocol ie:('google.com')"
        fi
elif grep -oP '^((?!-)[A-Za-z0-9-]{1,63}(?<!-)\.)+[A-Za-z]{2,6}$' <<< "$domain" >/dev/null 2>&1;
then
dig_domain
else
echo "Please enter a valid FQDN. ie:('google.com')"
fi
