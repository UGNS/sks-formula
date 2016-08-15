build_sks_db:
  local.state.apply:
    - tgt: {{ data.id }}
    - kwarg:
        mods:
          - sks.build
        test: False
