# clash-tap
`clash.exe` from [clash](https://github.com/Dreamacro/clash/releases)

`Country.mmdb` from [maxmind-geoip](https://github.com/Dreamacro/maxmind-geoip/releases)

`tun2socks.exe` is built from [tun2socks](https://github.com/ambrop72/badvpn/tree/master/tun2socks) (IPv4: TCP & UDP support, IPv6: TCP support only)

Use it with dashboard: http://yacd.haishan.me (Default for http://127.0.0.1:9090/ui) from [yacd](https://github.com/haishanh/yacd)

or http://clash.razord.top from [clash-dashboard](https://github.com/Dreamacro/clash-dashboard)

# how to use
Run `add_tap_device.bat` once

Then replace `以太网` in `config.yaml` with your current outbound netadapter name from

![image](https://user-images.githubusercontent.com/23069451/79680340-49bf9980-8241-11ea-86e3-46e39b576867.png)

Run `start.bat` to start

Run `stop.bat` to stop
