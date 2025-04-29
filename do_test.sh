#!/usr/bin/env bash

set -ue

echo ---cleanup verdaccio storage for test package---
docker compose exec verdaccio sh -c 'rm -rf /tmp/test'

echo ---create 1.0.0---
cd test-1.0.0
npm publish --registry http://localhost:5010
cd ..

echo ---create 1.0.1---
cd test-1.0.1
npm publish --registry http://localhost:5010
cd ..

echo ---ensure dist-tag link to 1.0.1---
npm dist-tag --registry http://localhost:5010 ls test

echo ---unpublish 1.0.0---
npm unpublish -ddd --registry http://localhost:5010 --force test@1.0.0


echo ---final check---
docker compose exec verdaccio sh -c 'ls -la /tmp/test'