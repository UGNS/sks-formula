# vim: sts=2:ts=2:et:ai
{% from "sks/map.jinja" import sks with context %}

sks:
  pkg.installed:
    - names:
  {% for name in sks.packages %}
        - {{ name }}
  {% endfor %}
  service.enabled:
    - name: {{ sks.service }}
    - require:
      - cmd: sks_pbuild

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
    - name: /usr/sbin/sks build /var/lib/sks/dump/*.pgp -n 2 -cache 50
    - creates: /var/lib/sks/DB/key
    - user: 'debian-sks'
    - require:
      - pkg: sks

sks_cleanup:
  cmd.wait:
    - name: /usr/sbin/sks cleandb
    - user: 'debian-sks'
    - onchanges:
      - cmd: sks_build
    - require:
      - pkg: sks

sks_pbuild:
  cmd.run:
    - name: /usr/sbin/sks pbuild --cache 20 -ptree_cache 70
    - creates: /var/lib/sks/PTree/ptree
    - user: 'debian-sks'
    - require:
      - cmd: sks_build
      - pkg: sks

