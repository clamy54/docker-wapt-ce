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
RUN yum update --assumeyes --skip-broken && yum install --assumeyes epel-release wget patch sudo && yum clean all
COPY files/wapt.repo /etc/yum.repos.d/wapt.repo
COPY files/run_wapt.sh /app/run_wapt.sh
COPY files/postconf.patch /app/postconf.patch
COPY files/configure_wapt.sh /app/configure_wapt.sh
RUN chmod +x /app/run_wapt.sh
RUN chmod +x /app/configure_wapt.sh
RUN wget -q -O /tmp/tranquil_it.gpg "https://wapt.tranquil.it/centos7/RPM-GPG-KEY-TISWAPT-7" && rpm --import /tmp/tranquil_it.gpg
RUN yum update --assumeyes --skip-broken && yum install --assumeyes postgresql96-server postgresql96-contrib tis-waptserver tis-waptsetup cabextract util-linux less sed && yum clean all
RUN patch -p0 /opt/wapt/waptserver/scripts/postconf.py < /app/postconf.patch
VOLUME /var/lib/pgsql/9.6
VOLUME /var/www/html
VOLUME /etc/nginx
VOLUME /opt/wapt/conf
RUN systemctl enable postgresql-9.6 
EXPOSE 80 443
CMD ["/app/run_wapt.sh"]
