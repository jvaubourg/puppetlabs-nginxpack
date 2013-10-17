#!/bin/bash

NGINX_DIR=/etc/nginx
NGINX_VHOSTS=$NGINX_DIR/sites-enabled
DEFAULT_LISTEN_CONF=$NGINX_DIR/include/default_listen.conf
DEFAULT_LISTEN_HTTPS_CONF=$NGINX_DIR/include/default_listen_https.conf

for vhost in $NGINX_VHOSTS/*; do
  [[ $vhost =~ default ]] && continue

  port=$(awk -F: '/ listen / { sub(";", "", $NF); print $NF }' $vhost | head -n1)
  https=$(grep -q '^\s*ssl on;\s*$' $vhost && echo true || echo false)
  ipv6=$(grep -q '^\s*listen\s*\[' $vhost && echo true || echo false)
  ipv4=$(grep -q '^\s*listen\s*[0-9]' $vhost && echo true || echo false)

  [ -z "$port" -o $port -eq 80 -o $port -eq 443 ] && continue

  if $ipv6; then
    $https && listen6_https="$listen6_https $port " || listen6="$listen6 $port "
  fi

  if $ipv4; then
    $https && listen4_https="$listen4_https $port " || listen4="$listen4 $port "
  fi
done

echo > $DEFAULT_LISTEN_CONF
echo > $DEFAULT_LISTEN_HTTPS_CONF

for port in $(printf "%s\n" $listen6_https | sort -un); do
  echo "listen [::]:$port default_server ipv6only=on;" >> $DEFAULT_LISTEN_HTTPS_CONF
done

for port in $(printf "%s\n" $listen4_https | sort -un); do
  echo "listen 0.0.0.0:$port default_server;" >> $DEFAULT_LISTEN_HTTPS_CONF
done

for port in $(printf "%s\n" $listen6 | sort -un); do
  echo $listen6_https | grep -q "\s${port}\s" && continue
  echo "listen [::]:$port default_server ipv6only=on;" >> $DEFAULT_LISTEN_CONF
done

for port in $(printf "%s\n" $listen4 | sort -un); do
  echo $listen4_https | grep -q "\s${port}\s" && continue
  echo "listen 0.0.0.0:$port default_server;" >> $DEFAULT_LISTEN_CONF
done

exit 0
