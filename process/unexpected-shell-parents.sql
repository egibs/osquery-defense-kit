SELECT p.name,
    p.path AS path,
    p.cmdline AS cmd,
    pp.name AS parent_name,
    pp.path AS parent_path,
    pp.cmdline AS parent_cmd,
    hash.sha256 AS parent_sha256
FROM processes p
    LEFT JOIN processes pp ON pp.pid = p.parent
    LEFT JOIN hash ON pp.path = hash.path
WHERE p.name IN ('sh', 'fish', 'zsh', 'bash', 'dash')
    -- Editors & terminals mostly
    AND pp.name NOT IN (
        'abrt-handle-eve',
        'alacritty',
        'bash',
        'build-script-build',
        'clang-11',
        'Code - Insiders Helper (Renderer)',
        'Code Helper (Renderer)',
        'collect2',
        'conmon',
        'containerd-shim',
        'dash',
        'demoit',
        'direnv',
        'find',
        'FinderSyncExtension',
        'fish',
        'go',
        'goland',
        'java',
        'ko',
        'kubectl',
        'make',
        'monorail',
        'nix',
        'node',
        'nvim',
        'perl',
        'PK-Backend',
        'python',
        'roxterm',
        'sdzoomplugin',
        'skhd',
        'swift',
        'systemd',
        'terminator',
        'test2json',
        'tmux:server',
        'tmux',
        'vi',
        'vim',
        'watch',
        'wezterm-gui',
        'xargs',
        'xcrun',
        'xfce4-terminal',
        'zsh'
    )
    AND parent_path NOT IN (
        '/Applications/Docker.app/Contents/MacOS/Docker',
        '/bin/dash',
        '/bin/sh',
        '/Library/Google/GoogleSoftwareUpdate/GoogleSoftwareUpdate.bundle/Contents/Helpers/GoogleSoftwareUpdateDaemon',
        '/opt/X11/libexec/launchd_startx',
        '/sbin/launchd',
        '/usr/bin/alacritty',
        '/usr/bin/apt-get',
        '/usr/bin/bash',
        '/usr/bin/bwrap',
        '/usr/bin/crond',
        '/usr/bin/login',
        '/usr/bin/man',
        '/usr/bin/sudo',
        '/usr/bin/xargs',
        '/usr/bin/zsh',
        '/usr/libexec/gnome-terminal-server',
        '/usr/libexec/periodic-wrapper',
        "/usr/bin/su"
    )

    -- npm run server
    AND NOT p.cmdline IN (
        'sh -c -- exec-bin node_modules/.bin/hugo/hugo server'
    )
    AND NOT (pp.name='sshd' AND p.cmdline LIKE "%askpass%")
    AND NOT p.cmdline LIKE "%/Library/Apple/System/Library/InstallerSandboxes%"
    AND NOT p.cmdline LIKE "%gcloud config config-helper%"
    AND NOT pp.cmdline LIKE "/Applications/Warp.app/%"
    AND NOT pp.cmdline LIKE "%brew.rb%"
    AND NOT pp.cmdline LIKE "%Code Helper%"
    AND NOT pp.cmdline LIKE "%gcloud.py config config-helper%"
    AND NOT pp.name LIKE "%term%"
    AND NOT pp.name LIKE "%Term%"
    AND NOT pp.name LIKE "Emacs%"
    AND NOT pp.name LIKE "terraform-provider-%"
    AND NOT pp.path LIKE "/Users/%/Library/Google/GoogleSoftwareUpdate/GoogleSoftwareUpdate.bundle/Contents/Helpers/GoogleSoftwareUpdateAgent.app/Contents/MacOS/GoogleSoftwareUpdateAgent"

    -- Oh, NixOS.
    AND NOT pp.name LIKE "%/bin/bash"
    AND NOT pp.name LIKE "%/bin/direnv"
    AND NOT parent_path LIKE "/nix/store/%sh"