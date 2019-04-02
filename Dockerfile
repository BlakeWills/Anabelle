FROM centos:7

WORKDIR /agent

COPY vsts-agent-linux-x64-2.148.1.tar.gz /agent

# Create user that will run the agent and install unzip.
RUN adduser agentusr \
    && yum install -y unzip

# Install terraform
RUN pushd /tmp \
    && curl https://releases.hashicorp.com/terraform/0.11.13/terraform_0.11.13_linux_amd64.zip -o terraform.zip \
    && unzip terraform.zip \
    && mv terraform /usr/bin/ \
    && terraform --version \
    && popd

# Install PIP & Ansible
RUN pushd /tmp \
    && curl "https://bootstrap.pypa.io/get-pip.py" -o "get-pip.py" \
    && python get-pip.py \
    && pip install ansible[azure] \
    && curl "https://raw.githubusercontent.com/ansible/ansible/devel/examples/ansible.cfg" -o "ansible.cfg" \
    && sed -i 's|#enable_plugins .*|enable_plugins = azure_rm, host_list, virtualbox, yaml, constructed|' ansible.cfg \
    && sed -i 's|#inventory_plugins .*|inventory_plugins = /usr/share/ansible/plugins/inventory|' ansible.cfg \
    && sed -i 's|#host_key_checking .*|host_key_checking = False|' ansible.cfg \
    && mkdir -p /etc/ansible/ \
    && mv ansible.cfg /etc/ansible/ansible.cfg \
    && ansible --version \
    && popd

COPY azure_rm.py /usr/share/ansible/plugins/inventory/

# Create an agent user and install the agent
RUN tar zxvf vsts-agent-linux-x64-2.148.1.tar.gz \
    && rm vsts-agent-linux-x64-2.148.1.tar.gz \
    && chmod +x ./config.sh \
    && chmod +x ./run.sh \
    && chmod +x ./bin/installdependencies.sh \
    && chown agentusr . \
    && ./bin/installdependencies.sh

# Copy this last to avoid invalidating the cached layers
COPY startup.sh /agent

USER agentusr

ENTRYPOINT ["/bin/bash", "./startup.sh"]