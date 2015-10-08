#!/bin/bash

# SKS build script.
# cd to directory with "dump" subdirectory, and run
# You might want to edit this file to reduce or increase memory usage
# depending on your system

trap ignore_signal USR1 USR2

ignore_signal() {
    echo "Caught user signal 1 or 2, ignoring"
}

fail() { echo Command failed unexpectedly.  Bailing out; exit -1; }

mode="build /var/lib/sks/dump*.pgp"

echo "=== Running build... ==="
if ! /usr/sbin/sks $mode -n 2 -cache 50; then fail; fi
echo === Cleaning key database... ===
if ! /usr/sbin/sks cleandb; then fail; fi
echo === Building ptree database... ===
if ! /usr/sbin/sks pbuild -cache 20 -ptree_cache 70; then fail; fi
echo === Done! ===

