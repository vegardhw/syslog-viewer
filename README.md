# Syslog Viewer

`syslog_viewer` is a minimal Docker container for tailing and aggregating syslog files from a host system. It is designed to be run alongside other services in a homelab, giving you a simple way to stream logs from a host into a single viewable stream.

Use this container to aggregate logs from systems such as Unraid and Home Assistant, making them easily accessible for powerful log viewers like [Dozzle](https://github.com/amir20/dozzle).

The container:

- Mounts a host directory containing syslog files (e.g. `/var/log/network`)
- Targets a specific host subdirectory via the `HOST_NAME` environment variable
- Concatenates logs from the past three days into a single file
- Tails and streams all matching `.log` files in real time

---

## How it works

### Container behavior

On startup, the container:

1. **Validates configuration**
   - Requires `HOST_NAME` to be set.
   - Expects logs to be located in `/host_syslog/$HOST_NAME` inside the container (typically mapped from a host directory).

2. **Builds a 3‑day log snapshot**
   - Computes a `start_date` three days ago.
   - Reads all `.log` files in `/host_syslog/$HOST_NAME`.
   - Filters lines with a date newer than or equal to `start_date`.
   - Writes the result to `/logs/three_days_logs.log` inside the container.

3. **Streams live logs**
   - Runs `tail -f` on all `.log` files in `/host_syslog/$HOST_NAME`.
   - Outputs a continuous combined stream to stdout (so you can follow it with `docker logs` or your orchestrator’s log viewer).

> Note: The container does not modify any host log files; it only reads from them.

---

## Example `docker-compose.yml`

Below is a minimal example of how this container is intended to be used:

```yaml path=null start=null
services:
  host1-syslog:
    build: .
    container_name: host1_syslog
    environment:
      - HOST_NAME=host1          # must match the subdirectory name under /var/log/network
    volumes:
      - /var/log/network:/host_syslog:ro
    restart: always