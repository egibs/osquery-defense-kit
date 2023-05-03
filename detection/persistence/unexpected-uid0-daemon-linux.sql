-- Unexpected long-running processes running as root
--
-- false positives:
--   * new software requiring escalated privileges
--
-- references:
--   * https://attack.mitre.org/techniques/T1543/
--
-- tags: persistent process state
-- platform: linux
SELECT
  CONCAT (
    p0.name,
    ',',
    REPLACE(
      p0.path,
      COALESCE(
        REGEX_MATCH (p0.path, "/nix/store/(.*?)/.*", 1),
        REGEX_MATCH (p0.path, "(\d[\.\d]+)/.*", 1),
        "3.11"
      ),
      "__VERSION__"
    ),
    ',',
    -- This is intentionally not euid, as everything is euid 0
    p0.uid,
    ',',
    CONCAT (
      SPLIT (p0.cgroup_path, "/", 0),
      ",",
      SPLIT (p0.cgroup_path, "/", 1)
    ),
    ',',
    f.mode
  ) AS exception_key,
  DATETIME(f.ctime, 'unixepoch') AS p0_changed,
  DATETIME(f.mtime, 'unixepoch') AS p0_modified,
  (strftime('%s', 'now') - p0.start_time) AS p0_runtime_s,
  -- Child
  p0.pid AS p0_pid,
  p0.path AS p0_path,
  p0.name AS p0_name,
  p0.cmdline AS p0_cmd,
  p0.cwd AS p0_cwd,
  p0.cgroup_path AS p0_cgroup,
  p0.euid AS p0_euid,
  p0_hash.sha256 AS p0_sha256,
  -- Parent
  p0.parent AS p1_pid,
  p1.path AS p1_path,
  p1.name AS p1_name,
  p1_f.mode AS p1_mode,
  p1.euid AS p1_euid,
  p1.cmdline AS p1_cmd,
  p1_hash.sha256 AS p1_sha256,
  -- Grandparent
  p1.parent AS p2_pid,
  p2.name AS p2_name,
  p2.path AS p2_path,
  p2.cmdline AS p2_cmd,
  p2_hash.sha256 AS p2_sha256
FROM
  processes p0
  LEFT JOIN file f ON p0.path = f.path
  LEFT JOIN hash p0_hash ON p0.path = p0_hash.path
  LEFT JOIN processes p1 ON p0.parent = p1.pid
  LEFT JOIN file p1_f ON p1.path = p1_f.path
  LEFT JOIN hash p1_hash ON p1.path = p1_hash.path
  LEFT JOIN processes p2 ON p1.parent = p2.pid
  LEFT JOIN hash p2_hash ON p2.path = p2_hash.path
WHERE
  p0.euid = 0
  AND p0.parent > 0
  AND p0.path != ""
  AND p0.start_time < (strftime('%s', 'now') - 900)
  AND exception_key NOT IN (
    'abrt-dump-journ,/usr/bin/abrt-dump-journal-core,0,system.slice,abrt-journal-core.service,0755',
    'abrt-dump-journ,/usr/bin/abrt-dump-journal-oops,0,system.slice,abrt-oops.service,0755',
    'abrt-dump-journ,/usr/bin/abrt-dump-journal-xorg,0,system.slice,abrt-xorg.service,0755',
    'abrtd,/usr/sbin/abrtd,0,system.slice,abrtd.service,0755',
    'accounts-daemon,/nix/store/__VERSION__/libexec/accounts-daemon,0,system.slice,accounts-daemon.service,0555',
    'accounts-daemon,/usr/lib/accounts-daemon,0,system.slice,accounts-daemon.service,0755',
    'accounts-daemon,/usr/libexec/accounts-daemon,0,system.slice,accounts-daemon.service,0755',
    'acpid,/usr/sbin/acpid,0,system.slice,acpid.service,0755',
    'agetty,/nix/store/__VERSION__/bin/agetty,0,system.slice,system-getty.slice,0555',
    'agetty,/usr/sbin/agetty,0,system.slice,system-getty.slice,0755',
    'agetty,/usr/sbin/agetty,0,system.slice,system-serial\x2dgetty.slice,0755',
    'alsactl,/usr/sbin/alsactl,0,system.slice,alsa-state.service,0755',
    'anacron,/usr/bin/anacron,0,system.slice,cronie.service,0755',
    'anacron,/usr/sbin/anacron,0,system.slice,crond.service,0755',
    'apcupsd,/usr/bin/apcupsd,0,system.slice,apcupsd.service,0755',
    'atd,/usr/sbin/atd,0,system.slice,atd.service,0755',
    'auditd,/usr/bin/auditd,0,system.slice,auditd.service,0755',
    'auditd,/usr/sbin/auditd,0,system.slice,auditd.service,0755',
    'blueman-mechanism.service,Bluetooth management mechanism,,200',
    'blueman-mechani,/usr/bin/python3.10,0,system.slice,blueman-mechanism.service,0755',
    'bluetoothd,/usr/lib/bluetooth/bluetoothd,0,system.slice,bluetooth.service,0755',
    'bluetoothd,/usr/libexec/bluetooth/bluetoothd,0,system.slice,bluetooth.service,0755',
    'boltd,/usr/lib/boltd,0,system.slice,bolt.service,0755',
    'boltd,/usr/libexec/boltd,0,system.slice,bolt.service,0755',
    'bpfilter_umh,/bpfilter_umh,0,,,',
    'containerd,/nix/store/__VERSION__/bin/containerd,0,system.slice,docker.service,0555',
    'containerd-shim,/usr/bin/containerd-shim-runc-v2,0,system.slice,containerd.service,0755',
    'containerd-shim,/usr/bin/containerd-shim-runc-v2,0,system.slice,docker.service,0755',
    'containerd,/usr/bin/containerd,0,system.slice,containerd.service,0755',
    'containerd,/usr/bin/containerd,0,system.slice,docker.service,0755',
    'crond,/usr/bin/crond,0,system.slice,cronie.service,0755',
    'crond,/usr/sbin/crond,0,system.slice,crond.service,0755',
    'cron,/usr/sbin/cron,0,system.slice,cron.service,0755',
    'cups-browsed,/usr/sbin/cups-browsed,0,system.slice,cups-browsed.service,0755',
    'cupsd,/usr/sbin/cupsd,0,system.slice,cups.service,0755',
    'dbus-daemon,/usr/bin/dbus-daemon,0,user.slice,user-1000.slice,0755',
    'dbus-launch,/usr/bin/dbus-launch,0,user.slice,user-1000.slice,0755',
    'dhclient,/usr/sbin/dhclient,0,system.slice,networking.service,0755',
    'dhcpcd,/nix/store/__VERSION__/bin/dhcpcd,0,system.slice,dhcpcd.service,0555',
    'dnf,/usr/bin/python__VERSION__,0,user.slice,user-1000.slice,0755',
    'dnsmasq,/usr/sbin/dnsmasq,0,system.slice,libvirtd.service,0755',
    'doas,/usr/bin/doas,1000,user.slice,user-1000.slice,4755',
    'dockerd,/nix/store/__VERSION__/libexec/docker/dockerd,0,system.slice,docker.service,0555',
    'dockerd,/usr/bin/dockerd,0,system.slice,docker.service,0755',
    'docker-proxy,/usr/bin/docker-proxy,0,system.slice,docker.service,0755',
    'docker-proxy,/usr/libexec/docker/docker-proxy,0,system.slice,docker.service,0755',
    'docker,/usr/bin/docker,0,user.slice,user-1000.slice,0755',
    'firewalld,/usr/bin/python3.10,0,system.slice,firewalld.service,0755',
    'firewalld,/usr/bin/python__VERSION__,0,system.slice,firewalld.service,0755',
    'fish,/usr/bin/fish,0,user.slice,user-1000.slice,0755',
    'flatpak-system-,/usr/libexec/flatpak-system-helper,0,system.slice,flatpak-system-helper.service,0755',
    'flatpak-system-,/usr/lib/flatpak-system-helper,0,system.slice,flatpak-system-helper.service,0755',
    'fprintd,/usr/libexec/fprintd,0,system.slice,fprintd.service,0755',
    'fstrim,/usr/sbin/fstrim,0,system.slice,fstrim.service,0755',
    'fusermount,/usr/bin/fusermount,1000,user.slice,user-1000.slice,4755',
    'fwupd,/usr/libexec/fwupd/fwupd,0,system.slice,fwupd.service,0755',
    'fwupd,/usr/lib/fwupd/fwupd,0,system.slice,fwupd.service,0755',
    'gdm3,/usr/sbin/gdm3,0,system.slice,gdm.service,0755',
    'gdm-session-wor,/usr/libexec/gdm-session-worker,0,user.slice,user-1000.slice,0755',
    'gdm-session-wor,/usr/libexec/gdm-session-worker,0,user.slice,user-42.slice,0755',
    'gdm-session-wor,/usr/lib/gdm-session-worker,0,user.slice,user-1000.slice,0755',
    'gdm-session-wor,/usr/lib/gdm-session-worker,0,user.slice,user-120.slice,0755',
    'gdm,/usr/bin/gdm,0,system.slice,gdm.service,0755',
    'gdm,/usr/sbin/gdm,0,system.slice,gdm.service,0755',
    'geoclue.service,Location Lookup Service,geoclue,500',
    'gpg-agent,/usr/bin/gpg-agent,0,system.slice,packagekit.service,0755',
    'gpg-agent,/usr/bin/gpg-agent,0,user.slice,user-1000.slice,0755',
    'gssproxy,/usr/sbin/gssproxy,0,system.slice,gssproxy.service,0755',
    'gvfsd-fuse,/usr/libexec/gvfsd-fuse,0,user.slice,user-1000.slice,0755',
    'haproxy,/usr/sbin/haproxy,0,system.slice,haproxy.service,0755',
    'iio-sensor-prox,/usr/libexec/iio-sensor-proxy,0,system.slice,iio-sensor-proxy.service,0755',
    'irqbalance,/usr/sbin/irqbalance,0,system.slice,irqbalance.service,0755',
    'iwd,/usr/lib/iwd/iwd,0,system.slice,iwd.service,0755',
    'launcher,/nix/store/__VERSION__/bin/launcher,0,system.slice,kolide-launcher.service,0555',
    'launcher,/usr/local/kolide-k2/bin/launcher-updates/__VERSION__/launcher,0,system.slice,launcher.kolide-k2.service,0755',
    'lightdm,/nix/store/__VERSION__/bin/lightdm,0,system.slice,display-manager.service,0555',
    'lightdm,/nix/store/__VERSION__/bin/lightdm,0,user.slice,user-1000.slice,0555',
    'lightdm,/usr/bin/lightdm,0,system.slice,lightdm.service,0755',
    'lightdm,/usr/bin/lightdm,0,user.slice,user-1000.slice,0755',
    'lightdm,/usr/bin/lightdm,0,user.slice,user-974.slice,0755',
    'lima-guestagent,/usr/local/bin/lima-guestagent,0,system.slice,lima-guestagent.service,0755',
    'low-memory-moni,/usr/libexec/low-memory-monitor,0,system.slice,low-memory-monitor.service,0755',
    'mcelog,/usr/sbin/mcelog,0,system.slice,mcelog.service,0755',
    'ModemManager,/usr/sbin/ModemManager,0,system.slice,ModemManager.service,0755',
    'multipathd,/usr/sbin/multipathd,0,system.slice,multipathd.service,0755',
    'nessusd,/opt/nessus/sbin/nessusd,0,system.slice,nessusd.service,0755',
    'nessus-service,/opt/nessus/sbin/nessus-service,0,system.slice,nessusd.service,0755',
    'networkd-dispat,/usr/bin/python3.10,0,system.slice,networkd-dispatcher.service,0755',
    'NetworkManager,/usr/bin/NetworkManager,0,system.slice,NetworkManager.service,0755',
    'NetworkManager,/usr/sbin/NetworkManager,0,system.slice,NetworkManager.service,0755',
    'nix-daemon,/nix/store/__VERSION__/bin/nix,0,system.slice,nix-daemon.service,0555',
    'nm-dispatcher,/usr/lib/nm-dispatcher,0,system.slice,NetworkManager-dispatcher.service,0755',
    'nm-openvpn-serv,/usr/libexec/nm-openvpn-service,0,system.slice,NetworkManager.service,0755',
    'nvidia-powerd,/usr/bin/nvidia-powerd,0,system.slice,nvidia-powerd.service,0755',
    'osqueryd,/nix/store/__VERSION__/bin/osqueryd,0,system.slice,kolide-launcher.service,0555',
    'osqueryd,/usr/local/kolide-k2/bin/osqueryd-updates/__VERSION__/osqueryd,0,system.slice,launcher.kolide-k2.service,0755',
    'osquery-extensi,/nix/store/__VERSION__/bin/osquery-extension.ext,0,system.slice,kolide-launcher.service,0555',
    'osqueryi,/usr/bin/osqueryd,0,user.slice,user-1000.slice,0755',
    'packagekitd,/usr/libexec/packagekitd,0,system.slice,packagekit.service,0755',
    'pacman,/usr/bin/pacman,0,user.slice,user-1000.slice,0755',
    'pcscd,/snap/yubioath-desktop/__VERSION__/usr/sbin/pcscd,0,system.slice,snap.yubioath-desktop.pcscd.service,0755',
    'pcscd,/usr/sbin/pcscd,0,system.slice,pcscd.service,0755',
    'perl,/nix/store/__VERSION__/bin/perl,0,system.slice,znapzend.service,0555',
    'polkitd,/usr/libexec/polkitd,0,system.slice,polkit.service,0755',
    'power-profiles-,/usr/libexec/power-profiles-daemon,0,system.slice,power-profiles-daemon.service,0755',
    'power-profiles-,/usr/lib/power-profiles-daemon,0,system.slice,power-profiles-daemon.service,0755',
    'pwrstatd,/usr/sbin/pwrstatd,0,system.slice,pwrstatd.service,0700',
    'rsyslogd,/usr/sbin/rsyslogd,0,system.slice,rsyslog.service,0755',
    'runc,/usr/bin/runc,0,system.slice,docker.service,0755',
    'scdaemon,/usr/libexec/scdaemon,0,system.slice,packagekit.service,0755',
    'scdaemon,/usr/libexec/scdaemon,0,user.slice,user-1000.slice,0755',
    'sedispatch,/usr/sbin/sedispatch,0,system.slice,auditd.service,0755',
    'sh,/nix/store/__VERSION__/bin/bash,0,system.slice,znapzend.service,0555',
    'smartd,/usr/sbin/smartd,0,system.slice,smartd.service,0755',
    'snapd,/snap/snapd/__VERSION__/usr/lib/snapd/snapd,0,system.slice,snapd.service,0755',
    'snapd,/usr/libexec/snapd/snapd,0,system.slice,snapd.service,0755',
    'snapd,/usr/lib/snapd/snapd,0,system.slice,snapd.service,0755',
    'sshd,/nix/store/__VERSION__/bin/sshd,0,system.slice,sshd.service,0555',
    'sshd,/nix/store/__VERSION__/bin/sshd,0,user.slice,user-1000.slice,0555',
    'sshd,/usr/bin/sshd,0,system.slice,sshd.service,0755',
    'sshd,/usr/sbin/sshd,0,system.slice,sshd.service,0755',
    'sshd,/usr/sbin/sshd,0,system.slice,ssh.service,0755',
    'sshd,/usr/sbin/sshd,0,user.slice,user-1000.slice,0755',
    'ssh,/nix/store/__VERSION__/bin/ssh,0,system.slice,znapzend.service,0555',
    'sssd_kcm,/usr/libexec/sssd/sssd_kcm,0,system.slice,sssd-kcm.service,0755',
    'sudo,/usr/bin/sudo,1000,user.slice,user-1000.slice,4111',
    'supergfxd,/usr/bin/supergfxd,0,system.slice,supergfxd.service,0755',
    'switcheroo-cont,/usr/libexec/switcheroo-control,0,system.slice,switcheroo-control.service,0755',
    'systemd-coredum,/nix/store/__VERSION__/lib/systemd/systemd-coredump,0,,,0555',
    'systemd-homed,/usr/lib/systemd/systemd-homed,0,system.slice,systemd-homed.service,0755',
    'systemd-hostnam,/usr/lib/systemd/systemd-hostnamed,0,system.slice,systemd-hostnamed.service,0755',
    'systemd-journal,/nix/store/__VERSION__/lib/systemd/systemd-journald,0,system.slice,systemd-journald.service,0555',
    'systemd-journal,/usr/lib/systemd/systemd-journald,0,system.slice,systemd-journald.service,0755',
    'systemd-localed,/usr/lib/systemd/systemd-localed,0,system.slice,systemd-localed.service,0755',
    'systemd-logind,/nix/store/__VERSION__/lib/systemd/systemd-logind,0,system.slice,systemd-logind.service,0555',
    'systemd-logind,/usr/lib/systemd/systemd-logind,0,system.slice,systemd-logind.service,0755',
    'systemd-machine,/usr/lib/systemd/systemd-machined,0,system.slice,systemd-machined.service,0755',
    'systemd-sleep,/usr/lib/systemd/systemd-sleep,0,system.slice,systemd-suspend.service,0755',
    'systemd-udevd,/nix/store/__VERSION__/bin/udevadm,0,system.slice,systemd-udevd.service,0555',
    'systemd-udevd,/usr/bin/udevadm,0,system.slice,systemd-udevd.service,0755',
    'systemd-userdbd,/usr/lib/systemd/systemd-userdbd,0,system.slice,systemd-userdbd.service,0755',
    'systemd-userwor,/usr/lib/systemd/systemd-userwork,0,system.slice,systemd-userdbd.service,0755',
    'tailscaled,/usr/bin/tailscaled,0,system.slice,tailscaled.service,0755',
    'tailscaled,/usr/sbin/tailscaled,0,system.slice,tailscaled.service,0755',
    '.tailscaled-wra,/nix/store/__VERSION__/bin/.tailscaled-wrapped,0,system.slice,tailscaled.service,0555',
    'thermald,/usr/sbin/thermald,0,system.slice,thermald.service,0755',
    'udisksd,/nix/store/__VERSION__/libexec/udisks2/udisksd,0,system.slice,udisks2.service,0555',
    'udisksd,/usr/libexec/udisks2/udisksd,0,system.slice,udisks2.service,0755',
    'udisksd,/usr/lib/udisks2/udisksd,0,system.slice,udisks2.service,0755',
    'unattended-upgr,/usr/bin/python3.10,0,system.slice,unattended-upgrades.service,0755',
    'unattended-upgr,/usr/bin/python3.9,0,system.slice,unattended-upgrades.service,0755',
    'upowerd,/usr/libexec/upowerd,0,system.slice,upower.service,0755',
    'upowerd,/usr/lib/upowerd,0,system.slice,upower.service,0755',
    'uresourced,/usr/libexec/uresourced,0,system.slice,uresourced.service,0755',
    '/usr/bin/monito,/usr/bin/perl,0,system.slice,monitorix.service,0755',
    'wpa_supplicant,/usr/bin/wpa_supplicant,0,system.slice,wpa_supplicant.service,0755',
    'wpa_supplicant,/usr/sbin/wpa_supplicant,0,system.slice,wpa_supplicant.service,0755',
    'xdg-desktop-por,/usr/libexec/xdg-desktop-portal,0,user.slice,user-1000.slice,0755',
    'xdg-desktop-por,/usr/libexec/xdg-desktop-portal-gnome,0,user.slice,user-1000.slice,0755',
    'xdg-document-po,/usr/libexec/xdg-document-portal,0,user.slice,user-1000.slice,0755',
    'xdg-permission-,/usr/libexec/xdg-permission-store,0,user.slice,user-1000.slice,0755',
    'X,/nix/store/__VERSION__/bin/Xorg,0,system.slice,display-manager.service,0555',
    'Xorg,/usr/lib/Xorg,0,system.slice,lightdm.service,0755',
    'yum,/usr/bin/python__VERSION__,0,user.slice,user-1000.slice,0755',
    'zed,/nix/store/__VERSION__/bin/zed,0,system.slice,zfs-zed.service,0555',
    'zfs-auto-snapsh,/nix/store/__VERSION__/bin/ruby,0,system.slice,zfs-snapshot-frequent.service,0555',
    'zfs-auto-snapsh,/nix/store/__VERSION__/bin/ruby,0,system.slice,zfs-snapshot-hourly.service,0555',
    'zfs,/nix/store/__VERSION__/bin/zfs,0,system.slice,zfs-snapshot-frequent.service,0555',
    'zfs,/nix/store/__VERSION__/bin/zfs,0,system.slice,zfs-snapshot-hourly.service,0555',
    'zfs,/nix/store/__VERSION__/bin/zfs,0,system.slice,znapzend.service,0555'
  )
  AND NOT exception_key LIKE 'abrt-dbus,/usr/sbin/abrt-dbus,0,system.slice,system-dbus%org.freedesktop.problems.slice,0755'
  AND NOT exception_key LIKE 'fusermount3,/usr/bin/fusermount3,%,user.slice,user-%.slice,4755'
  AND NOT p0.cgroup_path LIKE '/system.slice/docker-%'
GROUP BY
  p0.pid
