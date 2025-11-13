uci set firewall.@rule[-1].src='wan'
uci set firewall.@rule[-1].name='Web'
uci set firewall.@rule[-1].dest_port='80'
uci set firewall.@rule[-1].target='ACCEPT'
uci commit
