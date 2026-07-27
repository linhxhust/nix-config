{ config, lib, pkgs, ... }:

let
  homeDir = config.home.homeDirectory;
  cfg = config.jellyfinOpts;
  composeFile = "${homeDir}/jellyfin/docker-compose.yml";
  podmanCompose = "${pkgs.podman-compose}/bin/podman-compose";
in {
  options.jellyfinOpts.mediaPath = lib.mkOption {
    type = lib.types.str;
    # Switch to NFS mount point once configured, e.g. "/mnt/nas/media"
    default = "${homeDir}/mnt/nas/media";
    description = "Absolute path to the media directory (local or NFS mount point).";
  };

  config = {
    home.sessionVariables.PATH = "${pkgs.podman}/bin:${pkgs.podman-compose}/bin:$PATH";

    home.activation.jellyfinDirs = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      $DRY_RUN_CMD mkdir -p \
        "${homeDir}/.local/share/jellyfin/config" \
        "${homeDir}/.local/share/jellyfin/cache" \
        "${homeDir}/.local/share/jellyseerr" \
        "${homeDir}/.local/share/qbittorrent"
    '';

    home.file."jellyfin/docker-compose.yml".text = ''
      services:
        jellyfin:
          image: jellyfin/jellyfin:latest
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
          image: fallenbagel/jellyseerr:latest
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

      networks:
        media:
          driver: bridge
    '';

    systemd.user.services.jellyfin-stack = {
      Unit = {
        Description = "Jellyfin media stack (Jellyfin + Jellyseerr + qBittorrent)";
        After = [ "network-online.target" ];
        Wants = [ "network-online.target" ];
      };

      Service = {
        Type = "oneshot";
        RemainAfterExit = true;
        Environment = "PATH=${pkgs.podman}/bin:${pkgs.podman-compose}/bin:/run/wrappers/bin:/usr/bin:/bin";
        ExecStart = "${podmanCompose} -f ${composeFile} up -d --remove-orphans";
        ExecStop = "${podmanCompose} -f ${composeFile} down";
      };

      Install.WantedBy = [ "default.target" ];
    };
  };
}
