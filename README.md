# netdata-glibc
This is an automated build of [netdata](https://github.com/netdata/netdata) with [glibc package](https://github.com/sgerrand/alpine-pkg-glibc) for use with [nvidia-container-toolkit](https://github.com/NVIDIA/nvidia-docker). Also available in Unraid Community Applications.

Netdata with Nvidia GPU monitoring in a container. This image was created due to netdata/netdata using Alpine, a musl distribution, as a base. Nvidia drivers are only compatible with glibc distributions. This image uses netdata/netdata as a base and adds a GNU C library to run binaries linked against glibc. This image does not contain `nvidia-smi`, but is compatible with nvidia-container-toolkit and the Unraid Nvidia Plugin.

![nvidia-smi_netdata](https://user-images.githubusercontent.com/9123670/58919768-269d0180-86e4-11e9-8405-2a7b7c5917c7.png)

### Docker & nvidia-container-toolkit
```
docker run -d --name=netdata \
  -p 19999:19999 \
  -v <YOUR DOCKER CONFIGS>/netdata/config:/etc/netdata \
  -v <YOUR DOCKER CONFIGS>/netdata/lib:/var/lib/netdata \
  -v <YOUR DOCKER CONFIGS>/netdata/cache:/var/cache/netdata \
  -v /etc/passwd:/host/etc/passwd:ro \
  -v /etc/group:/host/etc/group:ro \
  -v /proc:/host/proc:ro \
  -v /sys:/host/sys:ro \
  -v /etc/os-release:/host/etc/os-release:ro \
  -e PGID=<HOST_DOCKER_PGID> \
  -e DO_NOT_TRACK= \
  --gpus all \
  --restart unless-stopped \
  --cap-add SYS_PTRACE \
  --security-opt apparmor=unconfined \
  d34dc3n73r/netdata-glibc
```

### Docker Compose
```
version: '3.8'
services:
  netdata:
    image: d34dc3n73r/netdata-glibc
    container_name: netdata
    hostname: example.com # set to fqdn of host
    ports:
      - 19999:19999
    restart: unless-stopped
    depends_on:
      - proxy
    cap_add:
      - SYS_PTRACE
    security_opt:
      - apparmor:unconfined
    environment:
      - DOCKER_HOST=proxy:2375
      - NETDATA_CLAIM_TOKEN= # See https://learn.netdata.cloud/docs/agent/claim#connect-an-agent-running-in-docker
      - NETDATA_CLAIM_URL=https://app.netdata.cloud
      - NETDATA_CLAIM_ROOMS= # See https://learn.netdata.cloud/docs/agent/claim#connect-an-agent-running-in-docker
    volumes:
      - <YOUR DOCKER CONFIGS>/netdata/config:/etc/netdata
      - <YOUR DOCKER CONFIGS>/netdata/lib:/var/lib/netdata
      - <YOUR DOCKER CONFIGS>/netdata/cache:/var/lib/cache/netdata
      - /etc/passwd:/host/etc/passwd:ro
      - /etc/group:/host/etc/group:ro
      - /proc:/host/proc:ro
      - /sys:/host/sys:ro
      - /etc/os-release:/host/etc/os-release:ro
    deploy:
      resources:
        reservations:
          devices:
          - driver: nvidia
            count: all
            capabilities: [gpu]
    proxy:
       container_name: proxy
       image: tecnativa/docker-socket-proxy
       volumes:
            - /var/run/docker.sock:/var/run/docker.sock:ro
       environment:
            - CONTAINERS=1
```  

### Prerequisites
 - Nvidia container toolkit installed on the host system
 - Nvidia drivers installed on the host system

### Container Name Resolution
#### docker run
 - Use the host docker PGID environment variable. 
 - Run `grep docker /etc/group | cut -d ':' -f 3` on the host system to get this value.
#### docker-compose
 - Container name resolution no longer requires the host docker PGID and mounting docker.sock. Instead this is handled by [HAProxy](https://docs.netdata.cloud/docs/running-behind-haproxy/) so that connections are restricted to read-only access. For more information check out the [Netdata Docker Installation Page](https://github.com/netdata/netdata/tree/master/packaging/docker). 

### Override Directory
Netdata now has override support built into their docker images. See https://learn.netdata.cloud/docs/agent/packaging/docker#configure-agent-containers for more information.

### Notes
- Netdata collects [anonymous statistics](https://docs.netdata.cloud/docs/anonymous-statistics/). If you wish to opt-out, set the envionrment varible `DO_NOT_TRACK=1`.
- This image uses the [default python.d.conf](https://github.com/netdata/netdata/blob/master/collectors/python.d.plugin/python.d.conf) with `nvidia_smi: yes` uncommented. Use `./edit-config` for futher customization. 
