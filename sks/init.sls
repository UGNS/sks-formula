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

