#!/bin/bash

# Set InfluxDB v2 API details
INFLUXDB_URL="http://INFLUX_IP:8086"
INFLUXDB_TOKEN="INFLUX_TOKEN"
INFLUXDB_ORG="ORG"
INFLUXDB_BUCKET="BUCKET_NAME"

# Set query
#QUERY="from(bucket:\"$INFLUXDB_BUCKET\") |> range(start:-1h) |> filter(fn:(r) => r[\"_measurement\"] == \"modbus\") |> filter(fn: (r) => r["name"] == "DRTU-1") |> filter(fn: (r) => r["_field"] == "DI1") |> aggregateWindow(every: v.windowPeriod, fn: mean, createEmpty: false) |> yield(name: "last")"

QUERY1="from(bucket: \"telegraf\") |> range(start:-1h) |> filter(fn: (r) => r[\"_measurement\"] == \"modbus\") |> filter(fn: (r) => r[\"_field\"] == \"DI1\") |> filter(fn: (r) => r[\"host\"] == \"modbus-monitor\") |> filter(fn: (r) => r[\"name\"] == \"DRTU-1\") |> filter(fn: (r) => r[\"slave_id\"] == \"1\") |> filter(fn: (r) => r[\"type\"] == \"discrete_input\")"

QUERY2="from(bucket: \"telegraf\") |> range(start:-1h) |> filter(fn: (r) => r[\"_measurement\"] == \"modbus\") |> filter(fn: (r) => r[\"_field\"] == \"DI2\") |> filter(fn: (r) => r[\"host\"] == \"modbus-monitor\") |> filter(fn: (r) => r[\"name\"] == \"DRTU-1\") |> filter(fn: (r) => r[\"slave_id\"] == \"1\") |> filter(fn: (r) => r[\"type\"] == \"discrete_input\")"

# Call InfluxDB v2 API to execute query and retrieve results
RESULTS1=$(curl --silent --request POST \
     --url "$INFLUXDB_URL/api/v2/query?org=$INFLUXDB_ORG" \
     --header "Authorization: Token $INFLUXDB_TOKEN" \
     --header 'Content-type: application/vnd.flux' \
     --data-raw "$QUERY1")


RESULTS2=$(curl --silent --request POST \
     --url "$INFLUXDB_URL/api/v2/query?org=$INFLUXDB_ORG" \
     --header "Authorization: Token $INFLUXDB_TOKEN" \
     --header 'Content-type: application/vnd.flux' \
     --data-raw "$QUERY2")


DI1=$(echo "$RESULTS1" | tail -12 | head -1 | cut -d ","  -f 7)
DI2=$(echo "$RESULTS2" | tail -12 | head -1 | cut -d ","  -f 7)


if [ "$DI1" -eq 1 ] && [ "$DI2" -eq 1 ]; then
	echo "DI1 and DI2 are 1"
else
	 echo "Error: At least one variable is not equal to 1."
fi
