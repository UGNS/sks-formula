build_sks_db:
  local.state.apply:
    - tgt: {{ data['id'] }}
    - mods: sks.build
    - test: False
