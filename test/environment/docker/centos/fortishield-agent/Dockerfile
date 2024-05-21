FROM centos:latest

RUN yum install which -y

RUN rpm --import http://packages.wazuh.com/key/GPG-KEY-WAZUH
COPY fortishield-repository.txt /etc/yum.repos.d/fortishield.repo

RUN yum install fortishield-agent -y

COPY entrypoint.sh /scripts/entrypoint.sh
