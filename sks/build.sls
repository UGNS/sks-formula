# vim: sts=2:ts=2:et:ai
{% from "sks/map.jinja" import sks with context %}

include:
  - sks

sks_build:
  cmd.script:
    - name: salt://sks/files/sks_build.sh
    - source: salt://sks/files/sks_build.sh
    - template: jinja
    - creates: {{ sks.datadir }}/PTree
    - user: {{ sks.user }}
    - context:
        build_opts: sks.get('build_opts')
        pbuild_opts: sks.get('pbuild_opts')
    - require:
      - pkg: sks

sks_cleanup_db:
  file.absent:
    - name: {{ sks.datadir }}/DB
    - onfail:
      - cmd: sks_build

sks_cleanup_ptree:
  file.absent:
    - name: {{ sks.datadir }}/PTree
    - onfail:
      - cmd: sks_build

{% if grains['os'] == 'Debian' %}
sks_default:
  file.replace:
    - name: /etc/default/sks
    - pattern: 'initstart=no'
    - repl: 'initstart=yes'
    - onchanges:
      - cmd: sks_build
    - watch_in:
      - service: sks
{% endif %}
