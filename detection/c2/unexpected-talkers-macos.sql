-- Unexpected programs communicating over non-HTTPS running from weird locations
--
-- references:
--   * https://attack.mitre.org/techniques/T1071/ (C&C, Application Layer Protocol)
--
-- tags: transient state net often
-- platform: macos
SELECT pos.protocol,
  pos.local_port,
  pos.remote_port,
  remote_address,
  pos.local_port,
  pos.local_address,
  CONCAT (MIN(p0.euid, 500), ',', s.authority) AS signed_exception,
  CONCAT (
    MIN(p0.euid, 500),
    ',',
    pos.protocol,
    ',',
    MIN(pos.remote_port, 32768),
    ',',
    REGEX_MATCH (p0.path, '.*/(.*?)$', 1),
    ',',
    p0.name
  ) AS unsigned_exception,
  -- Child
  p0.pid AS p0_pid,
  p0.path AS p0_path,
  s.authority AS p0_sauth,
  s.identifier AS p0_sid,
  p0.name AS p0_name,
  p0.cmdline AS p0_cmd,
  p0.cwd AS p0_cwd,
  p0.euid AS p0_euid,
  p0_hash.sha256 AS p0_sha256,
  -- Parent
  p0.parent AS p1_pid,
  p1.path AS p1_path,
  p1.name AS p1_name,
  p1.euid AS p1_euid,
  p1.cmdline AS p1_cmd,
  p1_hash.sha256 AS p1_sha256
FROM process_open_sockets pos
  LEFT JOIN processes p0 ON pos.pid = p0.pid
  LEFT JOIN hash p0_hash ON p0.path = p0_hash.path
  LEFT JOIN processes p1 ON p0.parent = p1.pid
  LEFT JOIN hash p1_hash ON p1.path = p1_hash.path
  LEFT JOIN file f ON p0.path = f.path
  LEFT JOIN signature s ON p0.path = s.path
WHERE pos.pid IN (
    SELECT pid
    from process_open_sockets
    WHERE protocol > 0
      AND NOT (
        remote_port IN (53, 443)
        AND protocol IN (6, 17)
      )
      AND remote_address NOT IN (
        '0.0.0.0',
        '::127.0.0.1',
        '127.0.0.1',
        '::ffff:127.0.0.1',
        '::1',
        '::'
      )
      AND remote_address NOT LIKE 'fe80:%'
      AND remote_address NOT LIKE '127.%'
      AND remote_address NOT LIKE '192.168.%'
      AND remote_address NOT LIKE '172.1%'
      AND remote_address NOT LIKE '172.2%'
      AND remote_address NOT LIKE '169.254.%'
      AND remote_address NOT LIKE '172.30.%'
      AND remote_address NOT LIKE '172.31.%'
      AND remote_address NOT LIKE '::ffff:172.%'
      AND remote_address NOT LIKE '10.%'
      AND remote_address NOT LIKE '::ffff:10.%'
      AND remote_address NOT LIKE 'fc00:%'
      AND remote_address NOT LIKE 'fdfd:%'
      AND state != 'LISTEN'
  ) -- Ignore most common application paths
  AND p0.path NOT LIKE '/Applications/%.app/Contents/MacOS/%'
  AND p0.path NOT LIKE '/Applications/%.app/Contents/%/MacOS/%'
  AND p0.path NOT LIKE '/Applications/%.app/Contents/Resources/%'
  AND p0.path NOT LIKE '/Library/Apple/%'
  AND p0.path NOT LIKE '/Library/Application Support/%/Contents/%'
  AND p0.path NOT LIKE '/System/%'
  AND p0.path NOT LIKE '/Users/%/bin/%'
  AND p0.path NOT LIKE '/opt/%/bin/%'
  AND p0.path NOT LIKE '/usr/bin/%'
  AND p0.path NOT LIKE '/usr/sbin/%'
  AND p0.path NOT LIKE '/usr/libexec/%'
  AND NOT signed_exception IN (
    '0,Developer ID Application: Tailscale Inc. (W5364U7YZB)',
    '500,Apple Mac OS Application Signing',
    '500,Developer ID Application: Zoom Video Communications, Inc. (BJ4HAAB9B3)',
    '500,Developer ID Application: Cisco (DE8Y96K9QP)',
    '500,Developer ID Application: Google LLC (EQHXZ8M8AV)',
    '500,Developer ID Application: Valve Corporation (MXGJJ98X76)',
    '500,Developer ID Application: The Browser Company of New York Inc. (S6N382Y83G)'
  )
  AND NOT (
    unsigned_exception = '500,6,80,main,main'
    AND p0.path LIKE '/var/folders/%/T/go-build%/b001/exe/main'
  )
  AND NOT (
    unsigned_exception IN (
      '500,6,0,gvproxy,gvproxy',
      '500,6,32768,gvproxy,gvproxy',
      '500,17,123,gvproxy,gvproxy'
    )
    AND p0.path LIKE '/opt/homebrew/Cellar/podman/%/libexec/podman/gvproxy'
  )
  AND NOT (
    unsigned_exception = '500,0,0,chainlink,chainlink'
    AND p0.path LIKE '/var/folders/%/T/go-build%/b001/exe/chainlink'
    AND remote_port = 0
    AND protocol = 0
  )
  AND NOT (
    unsigned_exception = '500,0,0,.Telegram-wrapped,.Telegram-wrapped'
    AND p0.path LIKE '/nix/store/%-telegram-desktop-%'
    AND remote_port = 0
    AND protocol = 0
  )
GROUP BY p0.cmdline
