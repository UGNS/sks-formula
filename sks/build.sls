# vim: sts=2:ts=2:et:ai
{% from "sks/map.jinja" import sks with context %}

include:
  - sks

mount_dump:
  mount.mounted:
    - name: /var/lib/sks/dump
    - device: sks.srv.dumain.com:/dumps/current
    - fstype: nfs
    - opts: defaults,ro,proto=tcp
    - persist: False

verify_dump:
  cmd.run:
    - name: md5sum -c --quiet metadata-sks-dump.txt && touch /tmp/metadata-sks-dump.ok
    - cwd: /var/lib/sks/dump
    - creates: /tmp/metadata-sks-dump.ok
    - require:
      - mount: mount_dump

sks_build:
  cmd.script:
    - name: salt://sks/files/sks_build.sh
    - source: salt://sks/files/sks_build.sh
    - template: jinja
    - creates: {{ sks.datadir }}/PTree
    - user: {{ sks.user }}
    - context:
        build_opts: {{ sks.build_opts }}
        pbuild_opts: {{ sks.pbuild_opts }}
    - require:
      - sls: sks
      - cmd: verify_dump

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

{% if grains.os == 'Debian' %}
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

unmount_dump:
  mount.unmounted:
    - name: /var/lib/sks/dump
    - device: sks.srv.dumain.com:/dumps/current
    - order: last
