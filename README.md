# Complete DNS lookup script
[![Build](https://travis-ci.org/joemccann/dillinger.svg?branch=master)](https://travis-ci.org/joemccann/dillinger)

---
## Description

It's a bash script to show a complete DNS lookup of a domain and it might be useful for Linux system/support engineers who handled client support.  I believe it helps for these guys to troubleshoot or easy way to find all the details in a single click.

----
## Feature
- DNS Lookup Script for troubleshooting 
- Including almost DNS Related commands in a single script
- Including whois details and telnet conncetivity (so need to install both that the packages)

---
## Pre-Requested Packages Installation 
_for-amazon-linux_
```sh
sudo yum -y install git 
sudo yum -y install bind-utils
sudo yum -y install telnet
sudo yum -y install whois
```

----
## How to use this script
```sh
git clone https://github.com/yousafkhamza/dns-lookup-bash-script.git
cd dns-lookup-bash-script
chmod +x dt.sh
```
_Alias Assgning for this script_
```sh
echo "alias dg='bash $(pwd)/dt.sh'" >> ~/.bashrc
source ~/.bashrc
```

## Script Running
```sh
dg geekflare.com                   #<--------------- Before set alias
or 
bash dt.sh                         #<-------------- On the Sript directory
```

## Output
```sh
# dg geekflare.com
xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
Dig +trace result of the geekflare.com
xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
geekflare.com.          30      IN      A       104.27.118.115
geekflare.com.          30      IN      A       104.27.119.115
geekflare.com.          86400   IN      DS      2371 13 2 CBAA2018F41B29985DAEDE7F127D4F9626ADA609665CEBAB0011903B 7C639254
geekflare.com.          172800  IN      NS      olga.ns.cloudflare.com.
geekflare.com.          172800  IN      NS      todd.ns.cloudflare.com.
xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
MX Record Result of the geekflare.com
xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
geekflare.com.          300     IN      MX      10 alt3.aspmx.l.google.com.
geekflare.com.          300     IN      MX      10 alt4.aspmx.l.google.com.
geekflare.com.          300     IN      MX      1 aspmx.l.google.com.
geekflare.com.          300     IN      MX      5 alt1.aspmx.l.google.com.
geekflare.com.          300     IN      MX      5 alt2.aspmx.l.google.com.
xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
TXT Record Resutl of the geekflare.com
xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
geekflare.com.          300     IN      TXT     "google-site-verification=MRSwa454qay1S6pwwixzoiZl08kfJfkhiQIslhok3-A"
geekflare.com.          300     IN      TXT     "ahrefs-site-verification_8eefbd2fe43a8728b6fd14a393e2aff77b671e41615d2c1c6fc365ec33a4d6d0"
geekflare.com.          300     IN      TXT     "yandex-verification: 42f25bad396e79f5"
geekflare.com.          300     IN      TXT     "v=spf1 include:_spf.google.com include:mailgun.org ~all"
geekflare.com.          300     IN      TXT     "google-site-verification=7QXbgb492Y5NVyWzSAgAScfUV3XIAGTKKZfdpCvcaGM"
xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
PTR record result of the 104.27.118.115
xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
Telnet trying to connect that IP Result of the alt3.aspmx.l.google.com
xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
IP: 172.217.194.27
xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
Telnet Result of IP: 104.27.118.115 && MX: alt3.aspmx.l.google.com and checking both 25 & 587
xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
IP:
          ------
MX: 220 mx.google.com ESMTP 26si18015154pgs.402 - gsmtp
xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
WHOIS Result of the geekflare.com
xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
   Registrar URL: http://www.cloudflare.com
   Registry Expiry Date: 2025-01-07T14:14:12Z
   Registrar: CloudFlare, Inc.
   Domain Status: clientTransferProhibited https://icann.org/epp#clientTransferProhibited
   Name Server: OLGA.NS.CLOUDFLARE.COM
   Name Server: TODD.NS.CLOUDFLARE.COM
xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
```

----
## Behind the code
```sh
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
echo "IP: `timeout 1 telnet $MX 587 > ~/Try; timeout 1 telnet $MX 25 >> ~/Try; cat ~/Try | grep -v -e '^$'| grep Trying | head -n1 | awk {'print $2'} | rev | cut -c4- |rev; rm -f ~/Try`"

#Netcatch Result for MX 25 & 587
echo "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
echo  "Telnet Result of IP: $IP && MX: $MX and checking both 25 & 587"
echo "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
echo "IP: `timeout 3 nc $IP 587 > ~/rre; timeout 1 nc $IP 25 >> ~/rre; cat ~/rre | grep -v -e '^$'| head -n1; rm -f ~/rre`"
echo "          ------"
echo "MX: `timeout 3 nc $MX 587 > ~/rre; timeout 1 nc $MX 25 >> ~/rre; cat ~/rre | grep -v -e '^$'| head -n1; rm -f ~/rre`"

#WHOIS Result for Domain
echo "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
echo  "WHOIS Result of the $domain"
echo "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
whois $domain | grep -E "Registrar:|Registry Expiry Date:|Registrar URL:|Name Server:|Expiration Date:|Status:|URL:"
echo "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
else
echo "Please enter a valid FQDN. eg:('google.com')"
fi
```
> Please note that I didn't use "dig +short" because I need to get the complete domain name and result so that's why I used this. If anyone comfertable with that kind of commands please be look and change the same as above file who needs to require that. 

---
### _Commands used (lookup)_
- _dig_
- _dig +trace_
- _telnet_
- _nc_
- _whois_

----
### _DNS Lookup working be like_

![alt text](https://i.ibb.co/Rybf9sQ/dns.png)

----
## Conclusion

It's a simple bash script for a complete DNS lookup details in a sing click. I hope it's usefull for who handles with a client support. Please let me know if you are facing any issues while using this script and please find the below contact details who needs to connect me.  

### ⚙️ Connect with Me 

<p align="center">
<a href="mailto:yousaf.k.hamza@gmail.com"><img src="https://img.shields.io/badge/Gmail-D14836?style=for-the-badge&logo=gmail&logoColor=white"/></a>
<a href="https://www.linkedin.com/in/yousafkhamza"><img src="https://img.shields.io/badge/LinkedIn-0077B5?style=for-the-badge&logo=linkedin&logoColor=white"/></a> 
<a href="https://www.instagram.com/yousafkhamza"><img src="https://img.shields.io/badge/Instagram-E4405F?style=for-the-badge&logo=instagram&logoColor=white"/></a>
<a href="https://wa.me/%2B917736720639?text=This%20message%20from%20GitHub."><img src="https://img.shields.io/badge/WhatsApp-25D366?style=for-the-badge&logo=whatsapp&logoColor=white"/></a><br />


