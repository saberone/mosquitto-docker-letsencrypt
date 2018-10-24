#!/bin/bash

# Check to see if certs for the specified domain exist
#	Attempt to retrieve certs if missing or
#	if present attempt to renew them
#
#       WARNING:
#		This script is called weekly from /etc/periodic/weekly/croncert.sh
#
#               Duing the weekly check, if certs are renewed,
#               the mosquitto process is restarted, causing
#               a brief (few second) unavoidable service disruption
#
# If the environment varialbe TESTCERT is defined, this script
# will use --staging --test-cert for obtaining a cert and --dry-run for renewal
# This allows the user to test out the configuration and connectivity for obtaining
# certs without running into LetsEncrypt limits. It's advisable to define TESTCERT
# when initially bringing up the container.  Once the logs (docker logs <containername>) 
# show that LetsEncrypt is working fine, then remove TESTCERT environment variable
# to let this script obtain and manage the real certificates
#

FOLDER="/etc/letsencrypt/live/$DOMAIN"
echo "Dealing with certificates..."
echo "Location: $FOLDER"
if [ -d "$FOLDER" ]; then
        echo "Certificates exist, attempting to renew..."
        if [ ! -z "$TESTCERT" ]; then
                echo "Renew dry run ..."
                certbot renew --dry-run --noninteractive --post-hook "/restart.sh"
        else
                echo "Renew certs ..."
                certbot renew --noninteractive --post-hook "/restart.sh"
        fi
else
        if [ ! -z "$DOMAIN" ]; then
                if [ ! -z "$EMAIL" ]; then
                        if [ ! -z "$TESTCERT" ]; then
                                echo "Obtaining TEST cert for $DOMAIN"
                                certbot certonly \
                                        --staging \
                                        --test-cert \
                                        --standalone \
                                        --agree-tos \
                                        --standalone-supported-challenges http-01 \
                                        -n \
                                        -d $DOMAIN \
                                        -m $EMAIL
                        else
                                echo "Obtaining cert for $DOMAIN"
                                certbot certonly \
                                        --standalone \
                                        --agree-tos \
                                        --standalone-supported-challenges http-01 \
                                        -n \
                                        -d $DOMAIN \
                                        -m $EMAIL
                        fi
                else
                        echo 'ERROR: $EMAIL must be defined'
                fi
        else
                echo 'ERROR: $DOMAIN must be defined'
        fi
fi
