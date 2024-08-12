ping_host=google.com
ping_log=/tmp/ping.log
min_ping_interval=10
max_ping_interval=30

curl_log=/tmp/curl.log
min_curl_interval=60
max_curl_interval=120
curl_url=http://speedtest.tele2.net/100MB.zip

first_timestamp=$(date +%s)

if [ -f ${ping_log} ]; then
    mv ${ping_log} ${ping_log}.${first_timestamp}
fi

if [ -f ${curl_log} ]; then
    mv ${curl_log} ${curl_log}.${first_timestamp}
fi

next_curl_timestamp=$(( RANDOM % (${max_curl_interval} - ${min_curl_interval} + 1) + ${min_curl_interval} + ${first_timestamp} ))

echo "Next curl in $(( ${next_curl_timestamp} - ${first_timestamp} )) seconds"

while true; do
    # ping
    start_timestamp=$(date +%s)
    ping_result=$(ping -c 10 ${ping_host} | tail -1 | awk '{print $4}' | cut -d '/' -f 2)
    relative_timestamp=$(( ${start_timestamp} - ${first_timestamp} ))
    echo "${relative_timestamp} ${ping_result}" >> ${ping_log}

    # curl
    curl_timestamp=$(date +%s)
    if [ $((curl_timestamp - next_curl_timestamp)) -ge 0 ]; then
        curl_result=$(curl -o /dev/null -s -w "%{time_total}" -H 'Cache-Control: no-cache' ${curl_url})
        relative_timestamp=$(( ${next_curl_timestamp} - ${first_timestamp} ))
        echo "${relative_timestamp} ${curl_result}" >> ${curl_log}
        next_curl_timestamp=$(( RANDOM % (${max_curl_interval} - ${min_curl_interval} +  1) + ${min_curl_interval} + $(date +%s) ))
        echo "Next curl in $(( ${next_curl_timestamp} - ${curl_timestamp} )) seconds"
    fi

    # wait
    random_ping_delay=$(( RANDOM % (${max_ping_interval} - ${min_ping_interval} + 1) + ${min_ping_interval} ))
    echo "Next ping in ${random_ping_delay} seconds"
    timestamp=$(date +%s)
    if [ $(( start_timestamp + random_ping_delay - timestamp )) -ge 0 ]; then
        sleep $(( start_timestamp + random_ping_delay - timestamp ))
    fi
done
