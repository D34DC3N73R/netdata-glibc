# netdata-glibc
This is an automated build of [netdata](https://github.com/netdata/netdata) with [glibc package](https://github.com/sgerrand/alpine-pkg-glibc) for use with [nvidia-docker2](https://github.com/NVIDIA/nvidia-docker).

Netdata with Nvidia GPU monitoring in a container. This image was created due to netdata/netdata using Alpine, a musl distribution, as a base. Nvidia Docker is incompatible with non-glibc distributions. This image uses netdata/netdata as a base and adds a GNU C library to run binaries linked against glibc. This image does not contain `nvidia-smi`, but is compatible with `nvidia-docker2`.

![nvidia-smi_netdata](https://user-images.githubusercontent.com/9123670/58919768-269d0180-86e4-11e9-8405-2a7b7c5917c7.png)

### docker run
```
docker run -d --name=netdata-glibc \
  -p 19999:19999 \
  -v /etc/passwd:/host/etc/passwd:ro \
  -v /etc/group:/host/etc/group:ro \
  -v /proc:/host/proc:ro \
  -v /sys:/host/sys:ro \
  -v /var/run/docker.sock:/var/run/docker.sock:ro \
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
        cap_add:
            - SYS_PTRACE
        security_opt:
            - apparmor:unconfined
        volumes:
            - /proc:/host/proc:ro
            - /sys:/host/sys:ro
    proxy:
       image: tecnativa/docker-socket-proxy
       volumes:
            - /var/run/docker.sock:/var/run/docker.sock:ro
       environment:
            - CONTAINERS=1
```  

### Notes
 - Container name resolution no longer  requires the host docker PGID and mounting docker.sock. Instead this is handled by [HAProxy](https://docs.netdata.cloud/docs/running-behind-haproxy/) so that connections are restricted to read-only access. For more information check out the [Netdata Docker Installation Page](https://github.com/netdata/netdata/tree/master/packaging/docker). 
 - This image uses the [default python.d.conf](https://github.com/netdata/netdata/blob/master/collectors/python.d.plugin/python.d.conf) with `nvidia_smi: yes` uncommented. Volume mount a custom python.d.conf to `/etc/netdata/python.d.conf` for futher customization. 
 - This assumes `/etc/docker/daemon.json` has been edited to make `nvidia` the default runtime. If not, include `--runtime=nvidia` in the run command, or add `runtime: nvidia` to docker compose v2.4 or previous. Note: the `runtime` option is not supported in docker compose v3.x.

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

