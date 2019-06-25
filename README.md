# netdata-glibc
This is an automated build of [netdata](https://github.com/netdata/netdata) with [glibc package](https://github.com/sgerrand/alpine-pkg-glibc) for use with [nvidia-docker2](https://github.com/NVIDIA/nvidia-docker).

Netdata with Nvidia GPU monitoring in a container. This image was created due to netdata/netdata using Alpine, a non-glibc distribution, as a base. Nvidia Docker is incompatible with non-glibc distributions. This image uses netdata/netdata as a base and adds a GNU C library to run binaries linked against glibc. This image does not contain `nvidia-smi`, but is compatible with `nvidia-docker2`.

![nvidia-smi_netdata](https://user-images.githubusercontent.com/9123670/58919768-269d0180-86e4-11e9-8405-2a7b7c5917c7.png)

### docker run
```
docker run -d --name=netdata-glibc \
  -p 19999:19999 \
  -e PGID=<host docker pgid> \
  -e NVIDIA_VISIBLE_DEVICES=all \
  -v /proc:/host/proc:ro \
  -v /sys:/host/sys:ro \
  -v /var/run/docker.sock:/var/run/docker.sock:ro \
  --cap-add SYS_PTRACE \
  --security-opt apparmor=unconfined \
  d34dc3n73r/netdata-glibc
```  

### docker-compose
```
    netdata:
        container_name: netdata-glibc
        image: d34dc3n73r/netdata-glibc
        ports:
            - 19999:19999
        environment:
            - PGID=<host docker pgid>
            - NVIDIA_VISIBLE_DEVICES=all
        cap_add:
            - SYS_PTRACE
        security_opt:
            - apparmor:unconfined
        volumes:
            - /var/run/docker.sock:/var/run/docker.sock:ro
            - /proc:/host/proc:ro
            - /sys:/host/sys:ro
```  

### Parameters
 - Run `grep docker /etc/group | cut -d ':' -f 3` on the host system to get the docker user PGID (999).

### Notes
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

