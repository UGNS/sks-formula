# vim: sts=2:ts=2:et:ai
{% from "sks/map.jinja" import sks with context %}

include:
  - sks

sksconf:
  file.managed:
    - name: {{ sks.confdir }}/sksconf
    - source: salt://sks/files/sksconf
    - template: jinja
    - require:
      - pkg: sks
    - watch_in:
      - service: sks

membership:
  file.managed:
    - name: {{ sks.confdir }}/membership
    - source: salt://sks/files/membership
    - template: jinja
    - require:
      - pkg: sks
    - watch_in:
      - service: sks

{% if not salt['file.directory_exists']('{0}/DB'.format(sks.datadir)) -%}
sks/keydump/ready:
  event.send:
    - data:
        status: "Ready for keydump to be imported"
{% endif -%}
