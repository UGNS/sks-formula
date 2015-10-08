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
      - cmd: sks_pbuild

{% if grains['os'] == 'Debian' %}
sks_default:
  file.replace:
    - name: /etc/default/sks
    - pattern: 'initstart=no'
    - repl: 'initstart=yes'
    - require:
      - cmd: sks_pbuild
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
  cmd.run:
    - name: /usr/sbin/sks build {{ sks.datadir }}/dump/*.pgp -n 2 -cache 50
    - creates: {{ sks.datadir }}/DB/key
    - user: {{ sks.user }}
    - require:
      - pkg: sks

sks_cleanup:
  cmd.run:
    - name: /usr/sbin/sks cleandb
    - user: {{ sks.user }}
    - require:
      - cmd: sks_build
      - pkg: sks

sks_pbuild:
  cmd.run:
    - name: /usr/sbin/sks pbuild -cache 20 -ptree_cache 70
    - creates: {{ sks.datadir }}/PTree/ptree
    - user: {{ sks.user }}
    - require:
      - cmd: sks_cleanup
      - pkg: sks

