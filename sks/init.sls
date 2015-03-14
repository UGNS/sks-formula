# vim: sts=2:ts=2:et:ai
{% from "sks/map.jinja" import sks with context %}

sks:
  {% if sks.packages is defined %}
  pkg.installed:
    - names:
  {% for name in sks.packages %}
        - {{ name }}
  {% endfor %}
    - watch_in:
      - service: sks
  {% endif %}
  service.running:
    - enable: True
    - require:
      - pkg: sks

sksconf:
  file.managed:
    - name: {{ sks.confdir }}/sksconf.new
    - source: salt://sks/files/sksconf
    - template: jinja
    - require:
      - pkg: sks
