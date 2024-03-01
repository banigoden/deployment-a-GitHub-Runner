Task 1
Git Repo for deploy github runner/Admin
1. Create poetry env for terraform amd ansible
2. pre-commit (see .pre-commit-config.yaml)
3. install comitizen (cz)
3. terraform  code deploy vm (env file )
4. Install GitHub Runner (prefered linux VMs) by ansible,
  4.1 create user + home
  4.2 install github runner-agent (ansible/manually)
  4.3 create systemd unit {jinja2 template}


Task 2
Repo for infra

1. Terraform code deploy 2 vm -<Github Actions
2. Ansible code  -<Github Actions
   2.1. Configuring VMs
   2.2 Install monitoring [Zabbix/Prom]
   2.3 Build docker images
   2.4 Render Docker compes file
   2.5 Deploy docker compose stack
