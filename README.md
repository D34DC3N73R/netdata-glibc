# netdata-glibc
[netdata](https://github.com/netdata/netdata) with [glibc package](https://github.com/sgerrand/alpine-pkg-glibc) for use with [nvidia-docker2](https://github.com/NVIDIA/nvidia-docker)

#### docker run
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

#### docker-compose
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

#### Parameters
 - Run `grep docker /etc/group | cut -d ':' -f 3` on the host system to get the docker user PGID.
 - This assumes you've edited `/etc/docker/daemon.json` to make `nvidia` the default runtime. If not, you'll need to add `--runtime=nvidia` to the container.

###### /etc/docker/daemon.json
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

#### Notes
This image uses the [default python.d.conf](https://github.com/netdata/netdata/blob/master/collectors/python.d.plugin/python.d.conf) with `nvidia_smi: yes` uncommented. Volume mount a custom python.d.conf to `/etc/netdata/python.d.conf` if you need futher customization. 
