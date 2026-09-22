#!/usr/bin/env bash

set -euo pipefail

BUCKET_NAME="residencia-foundation-site-692631066365"
DISTRIBUTION_ID="EZ4B6RXLJ0X1F"

echo "Gerando build..."
npm --prefix site run build

echo "Enviando assets versionados..."
aws s3 sync site/dist/ "s3://${BUCKET_NAME}/" \
  --delete \
  --exclude "index.html" \
  --cache-control "public,max-age=31536000,immutable"

echo "Enviando index.html..."
aws s3 cp site/dist/index.html "s3://${BUCKET_NAME}/index.html" \
  --content-type "text/html" \
  --cache-control "no-cache"

echo "Invalidando index.html no CloudFront..."
aws cloudfront create-invalidation \
  --distribution-id "${DISTRIBUTION_ID}" \
  --paths "/index.html"

echo "Deploy solicitado com sucesso."