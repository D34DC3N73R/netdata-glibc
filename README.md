# netdata-glibc
This is an automated build of [netdata](https://github.com/netdata/netdata) with [glibc package](https://github.com/sgerrand/alpine-pkg-glibc) for use with [nvidia-docker2 / nvidia-container-toolkit](https://github.com/NVIDIA/nvidia-docker). Now available in Unraid Community Applications.

Netdata with Nvidia GPU monitoring in a container. This image was created due to netdata/netdata using Alpine, a musl distribution, as a base. Nvidia Docker / Nvidia Container Toolkit is  only compatible with glibc distributions. This image uses netdata/netdata as a base and adds a GNU C library to run binaries linked against glibc. This image does not contain `nvidia-smi`, but is compatible with nvidia-docker2, nvidia-container-toolkit and the Unraid Nvidia Plugin.

![nvidia-smi_netdata](https://user-images.githubusercontent.com/9123670/58919768-269d0180-86e4-11e9-8405-2a7b7c5917c7.png)

### Docker 19.03 + nvidia-container-toolkit
```
docker run -d --name=netdata \
  -p 19999:19999 \
  -v /proc:/host/proc:ro \
  -v /sys:/host/sys:ro \
  -v /var/run/docker.sock:/var/run/docker.sock:ro \
  -e PGID=<HOST_DOCKER_PGID> \
  -e DO_NOT_TRACK= \
  --gpus all \
  --cap-add SYS_PTRACE \
  --security-opt apparmor=unconfined \
  d34dc3n73r/netdata-glibc
```

### < Docker 19.03 + nvidia-docker2
```
docker run -d --name=netdata \
  -p 19999:19999 \
  -v /proc:/host/proc:ro \
  -v /sys:/host/sys:ro \
  -v /var/run/docker.sock:/var/run/docker.sock:ro \
  -e PGID=<HOST_DOCKER_PGID> \
  -e NVIDIA_VISIBLE_DEVICES=all \
  -e DO_NOT_TRACK= \
  --cap-add SYS_PTRACE \
  --security-opt apparmor=unconfined \
  d34dc3n73r/netdata-glibc
```  

### docker-compose
```
version: '3'
services:
    netdata:
        container_name: netdata
        image: d34dc3n73r/netdata-glibc
        ports:
            - 19999:19999
        restart: unless-stopped
        environment:
            - NVIDIA_VISIBLE_DEVICES=all
            - DOCKER_HOST=proxy:2375
            - DO_NOT_TRACK=
        cap_add:
            - SYS_PTRACE
        security_opt:
            - apparmor:unconfined
        volumes:
            - /proc:/host/proc:ro
            - /sys:/host/sys:ro
    proxy:
       container_name: proxy
       image: tecnativa/docker-socket-proxy
       volumes:
            - /var/run/docker.sock:/var/run/docker.sock:ro
       environment:
            - CONTAINERS=1
```  

### Prerequisites
 - Nvidia container toolkit or Nvidia docker 2 installed on the host system
 - Nvidia drivers installed on the host system

### Container Name Resolution
#### docker run
 - Use the host docker PGID environment variable (999). 
 - Run `grep docker /etc/group | cut -d ':' -f 3` on the host system to get this value.
#### docker-compose
 - Container name resolution no longer requires the host docker PGID and mounting docker.sock. Instead this is handled by [HAProxy](https://docs.netdata.cloud/docs/running-behind-haproxy/) so that connections are restricted to read-only access. For more information check out the [Netdata Docker Installation Page](https://github.com/netdata/netdata/tree/master/packaging/docker). 

### Override Directory
This image includes an override feature. Volume mount the container path /etc/netdata anywhere you'd like to store your override files. The override directory contains placeholder directories, a generated netdata.conf file, and the edit-config script. The edit-config script can be used to make edits on any stock conf file. For instance, to edit python.d.conf do the following.
`docker exec -it netdata /etc/netdata/edit-config python.d.conf`
This command with load python.d.conf file from the stock configuration directory /usr/lib/netdata/conf.d using vi as an editor. The edited file will be saved to /etc/netdata and will override the stock configuration when netdata is restarted. Subsequent edits on a file will load the file from /etc/netdata.

### Notes
- Netdata collects [anonymous statistics](https://docs.netdata.cloud/docs/anonymous-statistics/). If you wish to opt-out, set the envionrment varible `DO_NOT_TRACK=1`.
- This image uses the [default python.d.conf](https://github.com/netdata/netdata/blob/master/collectors/python.d.plugin/python.d.conf) with `nvidia_smi: yes` uncommented. Volume mount a custom python.d.conf to `/etc/netdata/python.d.conf` for futher customization. 
- If using docker-compose v3+ `/etc/docker/daemon.json` must edited to make `nvidia` the default runtime. Example below. 
- If using docker-compose v2.4 or previous, add `runtime: nvidia`.
- Docker v19.03+ has native GPU support built into the runtime. See [Docker 19.03 + nvidia-container-toolkit](https://github.com/D34DC3N73R/netdata-glibc#docker-1903--nvidia-container-toolkit) above.

##### /etc/docker/daemon.json
```
{
    "default-runtime": "nvidia",
    "runtimes": {
        "nvidia": {
            "path": "/usr/bin/nvidia-container-runtime",
            "runtimeArgs": []
        }
    }
}
```
