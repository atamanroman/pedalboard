_default:
  @just --list

build:
  cargo make uf2 --release

flash: build
  # Hold pedal 1 while resetting/powering the XIAO first.
  @echo "Waiting for XIAO UF2..."
  @while [ ! -d "/Volumes/XIAO-SENSE" ]; do sleep 0.2; done
  cp pedalboard.uf2 "/Volumes/XIAO-SENSE/"
