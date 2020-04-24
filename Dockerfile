FROM centos:centos7
MAINTAINER clamy54
ENV container docker
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en
ENV LC_ALL en_US.UTF-8
RUN mkdir /app
WORKDIR /app
RUN yum  --assumeyes update; yum clean all
RUN yum -y install systemd; yum clean all; \
(cd /lib/systemd/system/sysinit.target.wants/; for i in *; do [ $i == systemd-tmpfiles-setup.service ] || rm -f $i; done); \
rm -f /lib/systemd/system/multi-user.target.wants/*;\
rm -f /etc/systemd/system/*.wants/*;\
rm -f /lib/systemd/system/local-fs.target.wants/*; \
rm -f /lib/systemd/system/sockets.target.wants/*udev*; \
rm -f /lib/systemd/system/sockets.target.wants/*initctl*; \
rm -f /lib/systemd/system/basic.target.wants/*;\
rm -f /lib/systemd/system/anaconda.target.wants/*;
VOLUME [ "/sys/fs/cgroup" ]
RUN yum update --assumeyes --skip-broken && yum install --assumeyes epel-release wget patch sudo grep gawk && yum clean all
COPY files/wapt.repo /etc/yum.repos.d/wapt.repo
COPY files/run_wapt.sh /app/run_wapt.sh
COPY files/postconf.patch /app/postconf.patch
COPY files/configure_wapt.sh /app/configure_wapt.sh
RUN chmod +x /app/run_wapt.sh
RUN chmod +x /app/configure_wapt.sh
RUN wget -q -O /tmp/tranquil_it.gpg "https://wapt.tranquil.it/centos7/RPM-GPG-KEY-TISWAPT-7" && rpm --import /tmp/tranquil_it.gpg
RUN yum update --assumeyes --skip-broken && yum install --assumeyes postgresql96-server postgresql96-contrib tis-waptserver tis-waptsetup cabextract util-linux less sed rsync krb5-workstation msktutil nginx-mod-http-auth-spnego && yum clean all
RUN patch -p0 /opt/wapt/waptserver/scripts/postconf.py < /app/postconf.patch
RUN mv /var/lib/pgsql/9.6 /var/lib/pgsql/9.6.orig && mv /var/www/html /var/www/html.orig && mv /etc/nginx /etc/nginx.orig && mv /opt/wapt/conf /opt/wapt/conf.orig && mv /opt/wapt/waptserver/ssl /opt/wapt/waptserver/ssl.orig
RUN mkdir -p /var/lib/pgsql/9.6 /var/www/html /etc/nginx /opt/wapt/conf /opt/wapt/waptserver/ssl && chown wapt:root /opt/wapt/conf && chown postgres:postgres /var/lib/pgsql/9.6 && chmod 700 /var/lib/pgsql/9.6
VOLUME /var/lib/pgsql/9.6
VOLUME /var/www/html
VOLUME /etc/nginx
VOLUME /opt/wapt/conf
VOLUME /opt/wapt/waptserver/ssl
RUN systemctl enable postgresql-9.6 
EXPOSE 80 443 8080
CMD ["/app/run_wapt.sh"]
