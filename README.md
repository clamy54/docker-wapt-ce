# Wapt Community Edition

WAPT is a deployment and IT asset management solution for Windows. 

The many options of the centralized management console allow you to automate the administration of your IT asset.

WAPT Community Edition is distributed under the GPLv3 license by Tranquil IT Systems.

This build is based on centos7 and wapt community edition.

*This isn't an official build and it comes with no warranty  ...*

## How to run

```shell
docker run --hostname wapt.myhostname.com -p 80:80 -p 443:443 -e WAPT_ADMIN_PASSWORD='adminpassword'  --privileged=true -v /sys/fs/cgroup:/sys/fs/cgroup:ro -d clamy54/wapt-ce:tag
```

Replace wapt.myhostname.com with the FQDN that wapt clients will use to join the wapt server (you can use your docker host fqdn or a cname pointing to it).
As this build relies on systemd, don't forget to put  `--privileged=true -v /sys/fs/cgroup:/sys/fs/cgroup:ro` in the command line.

The first run may takes some time because the post-install script generates DH parameters.

## Environment Variables

* `WAPT_ADMIN_PASSWORD` - Wapt administrator password. If not set, admin default password is set to *password* . If set to \*, a random password wil be generated. To view the generated password, use the *docker container logs \<container_name\>* command.
* `WAPT_AGENT_AUTHENTICATION` -  If not set, allow unauthenticated registration of clients ( same behavior as WAPT 1.3 ). If set to *kerberos*, kerberos authentication isrequired for machines registration. If set to *strong*,  Kerberos is disabled but registration require strong authentication.
* `DISABLE_NGINX` (only in latest build) - If set to 1, nginx is disabled in the container. You can configure your own nginx in another container or on host directly. SSL certificates can be found in the /opt/wapt/waptserver/ssl volume. If you install nginx directly on the host, then it can access multiple wapt container instances by using server_name based vhosts.
* `WAPTSERVER_PORT` (only in latest build) - If set, change waptserver process listening port (default : 8080). Must be a tcp port > 1024.

##  Volumes
To persist data, theses volumes are exposed and can be mounted to the local filesystem by adding -v option in the command line :

* `/var/lib/pgsql/9.6` - Postgres database. Also contains the lockfile used by the startup script for wapt-configuration at the  first-run only of the container.
* `/opt/wapt/conf` - Wapt config files & certificates
* `/etc/nginx` - Nginx configuration
* `/var/www/html` - Wapt files & repository
* `/opt/wapt/waptserver/ssl` - SSL certificates used by nginx (if you need them for external nginx)

## Examples
You can find one example (in french) of running multiple wapt instances of wapt on the same host using this container on [this site](https://www.be-root.com/2020/04/24/plusieurs-instances-wapt-sur-un-meme-serveur/) 
