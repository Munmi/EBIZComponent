#!/usr/bin/bash
########################################################
#SCRIPT TO CHECK THE RUNNING EBIZ AND SITEMINDER PROCESS
#WRITTEN BY: MUNMI UPADHYAY
########################################################

echo "Enter Your EMAIL ID"
echo "######################################
# e.g : xyz@optum.com
############################################"
read EMAIL
if [[ $EMAIL == *@optum.com ]];    
then
echo "SERVER","EBIZCOMPONENT","WAS","JBOSS","APACHE","SITEMINDER" > report.csv
for server in `cat serverlist`;
do 
var=$(ssh -T  -o ConnectTimeout=3 -o BatchMode=yes $server '/bin/bash -s' << EOF
########################################
#Checking ebiz components
########################################

 if ps -elf | grep -v grep | grep -i java > /dev/null ||  ps -elf | grep -v grep | grep -i httpd > /dev/null
 then
    echo "ebizComponent=Yes"
    echo "sep" 
    if ps -elf | grep -v grep | grep -i java | grep -i websphere > /dev/null
    then
	echo "WAS=Yes"
    else
	echo "WAS=No"
    fi
     echo "sep"
   if ps -elf | grep -v grep | grep -i java | grep -i jboss > /dev/null 
    then
        echo "JBOSS=Yes"
    else
        echo "JBOSS=No"
    fi
     echo "sep"
     if ps -elf | grep -v grep | grep -i httpd > /dev/null
      then
	echo "Apache=Yes"
	echo "sep"
	if ps -elf | grep -v grep | grep -i llawp > /dev/null
	then
		echo "Siteminder=Yes"
	else
		echo "Siteminder=No"
		
	fi
      else
	echo "Apache=No"
	echo "sep"
	 echo "Siteminder=No"
	fi
   else
	echo "ebizComponent=No"
	echo "sep"
	echo "WAS=No"
	echo "sep"
	echo "JBOSS=No"	
        echo "sep"
	echo "Apache=No"
	echo "sep"
	echo "Siteminder=No"
fi
EOF
)
if [[ $? -eq 0 ]]; then 
	EBIZ=$(echo $var | awk -F "sep" {'print $1'} | awk -F "=" {'print $2'})
	WAS=$(echo $var | awk -F "sep" {'print $2'} | awk -F "=" {'print $2'})
	JBOSS=$(echo $var | awk -F "sep" {'print $3'} | awk -F "=" {'print $2'})
	APACHE=$(echo $var | awk -F "sep" {'print $4'} | awk -F "=" {'print $2'})
	SITEMINDER=$(echo $var | awk -F "sep" {'print $5'} | awk -F "=" {'print $2'})
	echo $server,$EBIZ,$WAS,$JBOSS,$APACHE,$SITEMINDER >>report.csv
else
 echo "SSH not successful"
	EBIZ=No
	WAS=No
	JBOSS=No
	APACHE=No
	SITEMINDER=No
	echo $server,$EBIZ,$WAS,$JBOSS,$APACHE,$SITEMINDER >>report.csv
fi

done
uuencode report.csv report.csv | mail -s "Ebiz Components" $EMAIL
cat report.csv
else
echo "EMAIL Address entered is not correct"
exit
fi
