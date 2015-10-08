# vim: sts=2:ts=2:et:ai
{% from "sks/map.jinja" import sks with context %}

sks:
  pkg.installed:
    - names:
  {% for name in sks.packages %}
        - {{ name }}
  {% endfor %}
  service.running:
    - name: {{ sks.service }}
    - enable: True
    - watch:
      - file: sksconf
    - require:
      - cmd: sks_build

{% if grains['os'] == 'Debian' %}
sks_default:
  file.replace:
    - name: /etc/default/sks
    - pattern: 'initstart=no'
    - repl: 'initstart=yes'
    - require:
      - cmd: sks_build
{% endif %}

sksconf:
  file.managed:
    - name: {{ sks.confdir }}/sksconf
    - source: salt://sks/files/sksconf
    - template: jinja
    - require:
      - pkg: sks

membership:
  file.managed:
    - name: {{ sks.confdir }}/membership
    - source: salt://sks/files/membership
    - template: jinja
    - require:
      - pkg: sks

sks_build:
  cmd.script:
    - name: salt://{{ slspath }}/files/sks_build.sh
    - source: salt://{{ slspath }}/files/sks_build.sh
    - creates: {{ sks.datadir }}/PTree/ptree
    - user: {{ sks.user }}
    - onfailure:
      - cmd: sks_cleanup_db
      - cmd: sks_cleanup_ptree
    - require:
      - pkg: sks

sks_cleanup_db:
  cmd.wait:
    - name: rm -rf /var/lib/sks/DB
    - user: {{ sks.user }}
    - onlyif: test -d /var/lib/sks/DB

sks_cleanup_ptree:
  cmd.wait:
    - name: rm -rf /var/lib/sks/PTree
    - user: {{ sks.user }}
    - onlyif: test -d /var/lib/sks/PTree
