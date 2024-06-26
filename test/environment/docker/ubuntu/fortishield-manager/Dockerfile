FROM ubuntu:18.04

ARG fortishield_branch
ARG fortishield_api_branch
ARG fortishield_doc_branch

# enable SSH
RUN apt-get update && apt-get install -y openssh-server
RUN mkdir /var/run/sshd
RUN echo 'root:fortishield_admin' | chpasswd
RUN sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config

# SSH login fix. Otherwise user is kicked off after login
RUN sed 's@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@g' -i /etc/pam.d/sshd

ENV NOTVISIBLE "in users profile"
RUN echo "export VISIBLE=now" >> /etc/profile

EXPOSE 22

# install dependencies
RUN apt-get install python python-pip python3 python3-pip git gnupg2 gcc make vim libc6-dev curl policycoreutils automake autoconf libtool apt-transport-https lsb-release sqlite3 sudo -y

# install Fortishield
RUN git clone https://github.com/fortishield/fortishield && cd /fortishield && git checkout ${fortishield_branch}
# build Python dependencies
RUN sed -i 's!--index-url=file://${ROUTE_PATH}/${EXTERNAL_CPYTHON}/Dependencies/simple!!' /fortishield/src/Makefile
COPY preloaded-vars.conf /fortishield/etc/preloaded-vars.conf
RUN /fortishield/install.sh

# fortishield-documentation and dependencies
RUN git clone https://github.com/fortishield/fortishield-documentation && cd /fortishield-documentation && git checkout ${fortishield_doc_branch}
RUN pip3 install Sphinx==1.6.5 sphinx-rtd-theme==0.2.4 sphinxcontrib-images==0.7.0 sphinxprettysearchresults==0.3.5

# install pip libraries for development
RUN /var/ossec/framework/python/bin/pip3 install pytest defusedxml ptvsd pydevd-pycharm~=191.6605.12 freezegun

# install and configure Fortishield API
RUN curl -sL https://deb.nodesource.com/setup_12.x | bash - && apt-get install -y nodejs && npm config set user 0
RUN git clone https://github.com/fortishield/fortishield-api && cd /fortishield-api && git checkout ${fortishield_api_branch} && ./install_api.sh && npm install mocha apidoc -g && npm install glob supertest mocha should moment mochawesome sqlite3

# install ZSH
RUN apt-get install zsh -y
RUN cd /root && sh -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"

# copy script for running mocha tests
COPY run_mocha_tests.sh /fortishield-api

# copy script for generating Fortishield API reference
COPY generate_api_doc.sh /fortishield-api/doc/generate_api_doc.sh

# copy entrypoint and configuration files
COPY entrypoint.sh /scripts/entrypoint.sh
COPY master-ossec.conf /scripts/master-ossec.conf
COPY worker-ossec.conf /scripts/worker-ossec.conf
