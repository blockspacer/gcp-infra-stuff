
trackingfile=/tmp/trackingfile$$
echo "Logging in $trackingfile..."

echo "CTRL+C to stop"

URL=http://localhost:8000

function perf {
  curl -o /dev/null -s -w "%{time_connect} + %{time_starttransfer} = %{time_total}\n" "$1" >> $trackingfile &
}
index=1000000

while [ $index -gt 0 ] ; do

    perf $URL 

index=$((index-1))
done