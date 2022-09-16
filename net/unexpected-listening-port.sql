SELECT lp.address, lp.port, lp.protocol, p.pid, p.name, p.path, p.cmdline, p.cwd, hash.sha256
FROM listening_ports lp
    LEFT JOIN processes p ON lp.pid = p.pid
    LEFT JOIN hash ON p.path = hash.path
WHERE port != 0
    AND lp.address NOT IN ("224.0.0.251", "::1")
    AND lp.address NOT LIKE "127.0.0.%"
    AND lp.address NOT LIKE "172.1%"
    AND lp.address NOT LIKE "fe80::%"
    AND lp.address NOT LIKE "::ffff:127.0.0.%"
    AND NOT (lp.port > 1024 AND lp.protocol = 17)
    AND NOT (lp.port IN (8000,8080) AND lp.protocol=6)
    -- Linux --
    AND NOT (p.name IN ('spotify','Spotify') AND lp.port IN (1900,5353) AND lp.protocol=17)
    AND NOT (p.name IN ('spotify','Spotify') AND lp.port>32000 AND lp.protocol IN (6,17))
    AND NOT (p.name='.tailscaled-wra' AND p.cwd='/' AND lp.port=41641 AND lp.protocol=17)
    AND NOT (p.name='avahi-daemon' AND p.cwd='/etc/avahi' AND lp.port>5000 AND lp.protocol=17)
    AND NOT (p.name='Brackets-node' AND lp.port=8123 AND lp.protocol=6)
    AND NOT (p.name='chrome' AND lp.port>32000 AND lp.protocol IN (6,17))
    AND NOT (p.name='code' AND p.cwd='/' AND lp.port=43233 AND lp.protocol=6)
    AND NOT (p.name='code' AND p.cmdline LIKE "%extensionHost%" AND lp.port>32000 AND lp.protocol=6)
    AND NOT (p.name='containerd' AND p.cwd='/' AND lp.port=10010 AND lp.protocol=6)
    AND NOT (p.name='controlplane' AND p.cwd='/' AND lp.port IN (8008,8443) AND lp.protocol=6)
    AND NOT (p.name='coredns' AND p.cwd='/' AND lp.port IN (8181,8080,9153,53) AND lp.protocol=6)
    AND NOT (p.name='coredns' AND p.cwd='/' AND lp.port=53 AND lp.protocol=17)
    AND NOT (p.name='cri-dockerd' AND p.cwd='/' AND lp.port=39887 AND lp.protocol=6)
    AND NOT (p.name='cups-browsed' AND p.cwd='/' AND lp.port=631 AND lp.protocol=17)
    AND NOT (p.name='dashboard' AND p.cwd='/' AND lp.port=9090 AND lp.protocol=6)
    AND NOT (p.name='dhcpcd' AND port IN (17,58) AND lp.protocol=255)
    AND NOT (p.name='dhcpcd' AND port IN (546,68) AND lp.protocol=17)
    AND NOT (p.name='dleyna-renderer' AND lp.port>1024 AND lp.protocol IN (6,17))
    AND NOT (p.name='dockerd' AND p.cwd='/' AND lp.port=2376 AND lp.protocol=6)
    AND NOT (p.name='etcd' AND p.cwd='/' AND lp.port IN (2379,2380) AND lp.protocol=6)
    AND NOT (p.name='firefox' AND lp.port>32000 AND lp.protocol IN (6,17))
    AND NOT (p.name='.firefox-wrappe' AND lp.port>32000 AND lp.protocol IN (6,17))
    AND NOT (p.name='kdeconnectd' AND lp.port=1716 AND lp.protocol IN (6,17))
    AND NOT (p.name='kube-apiserver' AND p.cwd='/' AND lp.port IN (6443,8443) AND lp.protocol=6)
    AND NOT (p.name='kube-proxy' AND p.cwd='/' AND lp.port>10000 AND lp.protocol=6)
    AND NOT (p.name='kubelet' AND p.cwd='/' AND lp.port=10250 AND lp.protocol=6)
    AND NOT (p.name='kubectl' AND p.cmdline LIKE '%port-forward%' AND lp.port>1023 AND lp.protocol=6)
    AND NOT (p.name='metrics-sidecar' AND p.cwd='/' AND lp.port=8000 AND lp.protocol=6)
    AND NOT (p.name='NetworkManager' AND p.cwd='/' AND lp.port=58 AND lp.protocol=255)
    AND NOT (p.name IN ('nginx', 'crc') AND p.cwd='/' AND lp.port IN (80,443) AND lp.protocol=6)
    AND NOT (p.name='plugin-container' AND lp.port>32000 AND lp.protocol IN (6,17))
    AND NOT (p.name='node' AND lp.port>1024 AND lp.protocol = 6)
    AND NOT (p.name IN ('registry', 'registry-redirect') AND lp.port>1024 AND lp.protocol = 6)
    AND NOT (p.name='sshd' AND p.cwd='/' AND lp.port=22 AND lp.protocol=6)
    AND NOT (p.name='tailscaled' AND lp.port=4161 AND lp.protocol=6)
    AND NOT (p.name='tailscaled' AND lp.port>40000 AND lp.protocol IN (6,17))
    AND NOT (p.name='Sonos' AND p.cwd='/' AND lp.port=3400 AND lp.protocol=6)
    AND NOT (p.name='docker-proxy' AND lp.port>1024 AND lp.protocol=6)
    -- macOS --
    AND NOT (p.name IN ('launchd','netbiosd') AND p.cwd='/' AND lp.port IN (137,138) AND lp.protocol=17)
    AND NOT (p.name='Arc Helper' AND p.cwd='/' AND lp.port>5000 AND lp.protocol=17)
    AND NOT (p.name='Arc' AND p.cwd='/' AND lp.port>5000 AND lp.protocol=17)
    AND NOT (p.name='Code Helper' AND lp.port > 5000 AND lp.protocol=6)
    AND NOT (p.name='com.docker.backend' AND p.cwd LIKE '/Users/%/Library/Containers/com.docker.docker/Data' AND lp.port > 79 AND lp.protocol=6)
    AND NOT (p.name='CommCenter' AND p.cwd='/' AND lp.port=5060 AND lp.protocol IN (6,17))
    AND NOT (p.name='configd' AND p.cwd='/' AND lp.port IN (68,546) AND lp.protocol=17)
    AND NOT (p.name='ControlCenter' AND p.cwd='/' AND lp.port IN (5000,7000) AND lp.protocol=6)
    AND NOT (p.name='cupsd' AND p.cwd='/' AND lp.port=631 AND lp.protocol=6)
    AND NOT (p.name='Dropbox' AND p.cwd='/' AND lp.port=17500 AND lp.protocol IN (6,17))
    AND NOT (p.name='EEventManager' AND p.cwd='/' AND lp.port=2968 AND lp.protocol IN (6,17))
    AND NOT (p.name='fake' AND p.cwd LIKE '/Users/%/api-impl' AND lp.port IN (2112,8080) AND lp.protocol=6)
    AND NOT (p.name='hugo' AND lp.port>1024 AND lp.protocol=6)
    AND NOT (p.name='IPNExtension' AND p.cwd LIKE '/Users/%/Library/Containers/io.tailscale.ipn.macos.network-extension/Data' AND lp.port>32000 AND lp.protocol IN (6,17))
    AND NOT (p.name='launchd' AND p.cwd='/' AND lp.port=22 AND lp.protocol=6)
    AND NOT (p.name='GarageBand' AND lp.port=51100 AND lp.protocol=6)

    AND NOT (p.name='mariadbd' AND p.cwd='/opt/homebrew/var/mysql' AND lp.port=3306 AND lp.protocol=6)
    AND NOT (p.name='node' AND p.cwd LIKE '/Users/%/app' AND lp.port>5000 AND lp.protocol=6)
    AND NOT (p.name='mysqld' AND port IN (3306,33060) AND lp.protocol=6)
    AND NOT (p.name='apcupsd' AND p.cwd='/' AND lp.port=3551 AND lp.protocol=6)
    AND NOT (p.name='rapportd' AND p.cwd='/' AND lp.port=3722 AND lp.protocol=17)
    AND NOT (p.name='RescueTime' AND p.cwd='/' AND lp.port=16587 AND lp.protocol=6)
    AND NOT (p.name='kdenlive' AND lp.port=1337 AND lp.protocol=6)
    AND NOT (p.name='sharingd' AND p.cwd='/' AND lp.port IN (8770,8771) AND lp.protocol=6)
    AND NOT (p.name='syncthing' AND lp.port > 20000 AND lp.protocol IN (6,17))
    AND NOT (p.name='steam' AND lp.port >20000 AND lp.protocol IN (6,17))
    AND NOT (p.name='systemd-resolve' AND p.cwd='/' AND lp.port=5355 AND lp.protocol IN (6,17))
    AND NOT (p.name='X11.bin' AND lp.port=6000 AND lp.protocol=6)
    AND NOT (p.path LIKE "/ko-app/%" AND lp.port > 1024 and lp.protocol=6)

    -- Ephemerals
    AND NOT (p.name IN (
        'LogiMgrDaemon',
        'rapportd',
        'vpnkit-bridge',
        'com.docker.vpnkit',
        '1Password-BrowserSupport',
        'remoted',
        'AirPlayXPCHelper',
        'Sketch',
        'SketchMirrorHelper'
    ) AND lp.port>49000 AND lp.protocol IN (6,17))

