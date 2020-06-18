import os

import testinfra.utils.ansible_runner

# https://testinfra.readthedocs.io/en/latest/modules.html

testinfra_hosts = testinfra.utils.ansible_runner.AnsibleRunner(
    os.environ['MOLECULE_INVENTORY_FILE']).get_hosts('instance')

def test_services_running(host):
    fluentd = host.process.filter(user='root', comm='fluentd')
    telegraf = host.process.filter(user='telegraf', comm='telegraf')

    assert len(fluentd) >= 1
    assert len(telegraf) >= 1

def test_telegraf(host):
    r = host.ansible("uri", "url=http://localhost:9100/metrics return_content=yes", check=False)

    assert '# HELP' in r['content']

def test_nginx_vhosts(host):
    application = host.ansible("uri", "url=http://127.0.0.1/ return_content=yes headers={'Host':'application.com'}", check=False)

    assert 'riot' in application['content']
