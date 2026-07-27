{ config, lib, pkgs, ... }:

let
  homeDir = config.home.homeDirectory;
  cfg = config.jellyfinOpts;
  composeFile = "${homeDir}/jellyfin/docker-compose.yml";
  dockerBin = "${pkgs.docker}/bin/docker";
in {
  options.jellyfinOpts.mediaPath = lib.mkOption {
    type = lib.types.str;
    default = "/mnt/nas/media";
    description = "Absolute path to the media directory (local or NFS mount point).";
  };

  config = {
    home.packages = [ pkgs.docker ];

    home.activation.jellyfinDirs = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      $DRY_RUN_CMD mkdir -p \
        "${homeDir}/.local/share/jellyfin/config" \
        "${homeDir}/.local/share/jellyfin/cache" \
        "${homeDir}/.local/share/jellyseerr" \
        "${homeDir}/.local/share/qbittorrent" \
        "${homeDir}/.local/share/radarr" \
        "${homeDir}/.local/share/radarr4k" \
        "${homeDir}/.local/share/sonarr" \
        "${homeDir}/.local/share/prowlarr"
    '';

    home.file."jellyfin/docker-compose.yml".text = ''
      services:
        jellyfin:
          image: docker.io/jellyfin/jellyfin:latest
          container_name: jellyfin
          ports:
            - "8096:8096"
            - "8920:8920"
          volumes:
            - ${homeDir}/.local/share/jellyfin/config:/config
            - ${homeDir}/.local/share/jellyfin/cache:/cache
            - ${cfg.mediaPath}:/media:ro
          networks:
            - media
          restart: unless-stopped

        jellyseerr:
          image: docker.io/fallenbagel/jellyseerr:latest
          container_name: jellyseerr
          environment:
            - TZ=Asia/Ho_Chi_Minh
          ports:
            - "5055:5055"
          volumes:
            - ${homeDir}/.local/share/jellyseerr:/app/config
          networks:
            - media
          restart: unless-stopped

        qbittorrent:
          image: lscr.io/linuxserver/qbittorrent:latest
          container_name: qbittorrent
          environment:
            - PUID=1000
            - PGID=1000
            - TZ=Asia/Ho_Chi_Minh
            - WEBUI_PORT=8080
          ports:
            - "8080:8080"
            - "6881:6881"
            - "6881:6881/udp"
          volumes:
            - ${homeDir}/.local/share/qbittorrent:/config
            - ${cfg.mediaPath}:/media
          networks:
            - media
          restart: unless-stopped

        radarr:
          image: lscr.io/linuxserver/radarr:latest
          container_name: radarr
          environment:
            - PUID=1000
            - PGID=1000
            - TZ=Asia/Ho_Chi_Minh
          ports:
            - "7878:7878"
          volumes:
            - ${homeDir}/.local/share/radarr:/config
            - ${cfg.mediaPath}:/media
          networks:
            - media
          restart: unless-stopped

        prowlarr:
          image: lscr.io/linuxserver/prowlarr:latest
          container_name: prowlarr
          environment:
            - PUID=1000
            - PGID=1000
            - TZ=Asia/Ho_Chi_Minh
          ports:
            - "9696:9696"
          volumes:
            - ${homeDir}/.local/share/prowlarr:/config
          networks:
            - media
          restart: unless-stopped

        radarr4k:
          image: lscr.io/linuxserver/radarr:latest
          container_name: radarr4k
          environment:
            - PUID=1000
            - PGID=1000
            - TZ=Asia/Ho_Chi_Minh
          ports:
            - "7879:7878"
          volumes:
            - ${homeDir}/.local/share/radarr4k:/config
            - ${cfg.mediaPath}:/media
          networks:
            - media
          restart: unless-stopped

        sonarr:
          image: lscr.io/linuxserver/sonarr:latest
          container_name: sonarr
          environment:
            - PUID=1000
            - PGID=1000
            - TZ=Asia/Ho_Chi_Minh
          ports:
            - "8989:8989"
          volumes:
            - ${homeDir}/.local/share/sonarr:/config
            - ${cfg.mediaPath}:/media
          networks:
            - media
          restart: unless-stopped

      networks:
        media:
          driver: bridge
    '';

    systemd.user.services.jellyfin-stack = {
      Unit = {
        Description = "Jellyfin media stack (Jellyfin + Jellyseerr + qBittorrent + Radarr + Sonarr)";
        After = [ "network-online.target" ];
        Wants = [ "network-online.target" ];
      };

      Service = {
        Type = "oneshot";
        RemainAfterExit = true;
        Environment = "PATH=${pkgs.docker}/bin:/usr/bin:/bin";
        # sg activates the docker group for the process so the socket is
        # accessible even when the systemd --user session predates usermod.
        ExecStart = "/usr/bin/sg docker -c '${dockerBin} compose -f ${composeFile} up -d --remove-orphans'";
        ExecStop = "/usr/bin/sg docker -c '${dockerBin} compose -f ${composeFile} down'";
      };

      Install.WantedBy = [ "default.target" ];
    };
  };
}
