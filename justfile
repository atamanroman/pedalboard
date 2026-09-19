_default:
  @just --list

build:
  cargo make uf2 --release

flash: build
  # Hold pedal 1 while resetting/powering the XIAO first.
  @echo "Waiting for XIAO UF2..."
  @while [ ! -d "/Volumes/XIAO-SENSE" ]; do sleep 0.2; done
  cp pedalboard.uf2 "/Volumes/XIAO-SENSE/" 2> /dev/null || true

# Run the project site locally
site-dev:
  cd site && zola serve --drafts

# Build the project site; optionally override its base URL
site-build base_url="":
  cd site && zola build {{ if base_url == "" { "" } else { "--base-url=" + base_url } }}

# Validate the project site and its links
site-check:
  cd site && zola check

# Build and publish the project site to Cloudflare
site-deploy: (site-build "https://pedalboard.atamanroman.dev")
  cd site && npx wrangler deploy
