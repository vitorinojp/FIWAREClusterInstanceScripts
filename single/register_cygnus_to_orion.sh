#!/bin/bash
#Register Cygnus as a subscriber, to Orion, of all changes to ttnmapper/lorawan
curl --location --request POST 'http://192.168.1.103:1026/v2/subscriptions/' \
--header 'fiware-service: ttnmapper' \
--header 'fiware-servicepath: /lorawan' \
--header 'Content-Type: application/json' \
--data-raw '{
  "description": "Notify Cygnus of all changes",
  "subject": {
    "entities": [
      {
        "idPattern": ".*"
      }
    ]
  },
  "notification": {
    "http": {
      "url": "http://cygnus:5051/notify"
    }
  }
}'
