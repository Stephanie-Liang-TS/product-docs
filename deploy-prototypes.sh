#!/bin/bash
# Auto-deploy prototypes from GitHub repo to zylos150.coco.site
# Run after git pull to sync prototype files to the web server

REPO_DIR="/home/cocoai/zylos/workspace/product-docs"
PUBLIC_DIR="/home/cocoai/zylos/http/public"
PROTO_DIR="$REPO_DIR/workspace/prototypes"

cd "$REPO_DIR" && git pull --rebase origin main 2>/dev/null

if [ -d "$PROTO_DIR" ]; then
  for f in "$PROTO_DIR"/*.html; do
    [ -f "$f" ] && cp "$f" "$PUBLIC_DIR/"
  done
fi
