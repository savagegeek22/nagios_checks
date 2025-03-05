#!/bin/bash -x

#
#
#  NOTE That this is all of the macros for NAGIOS to use
# https://assets.nagios.com/downloads/nagioscore/docs/nagioscore/3/en/macrolist.html
#
#
# Rocket.Chat webhook URL
#
# Old WebHook from Onomonopia
# WEBHOOK_URL="https://onomonopia.savagegeek.net/hooks/644cbe70f3cf36b7511ae96d/TqD8cYgWHqXeyTTPrZSr235dkXccDmJhPNqrvz5c7DG7mYgp"

WEBHOOK_URL="https://onomonopia.savagegeek.net/hooks/65af309a786b0b02c77e67ff/nwW5ijqrhy3nqLD6TLz6QGyFatPABtdmFQhTaYoLsvy9c89t"

# Get the current date and time
CURRENT_TIME=$(TZ="America/New_York" date +"%I:%M %p %m-%d-%Y")
#CURRENT_TIME=$(date -u +"%I:%M %p %m-%d-%Y" --timezone=America/New_York)
#CURRENT_TIME=$(TZ="America/New_York" date -u +"%I:%M %p %m-%d-%Y")


# JSON payload for the message

MESSAGE='{
  "text": "\n\n \n\n:drpepper: *Check Your Chit!!* :medmari:\n\n*Time*: '$CURRENT_TIME'\n\n:point_right: [Monitoring Link](http://sg-centreon-01.savagegeek.com) :point_left: \n\n*Host*: '$1'\n\nService: '$4'\n\nAddress: '$7'\nHostState: '$2'\n\n\nServiceState: *'$5'*\n*Output*: '$6'\n",
  "username": "Centreon",
  "icon_url": "https://clipground.com/images/png-logos-1.png"
}'



    curl -X POST -H "Content-Type: application/json" -d "$MESSAGE" "$WEBHOOK_URL"

#done
