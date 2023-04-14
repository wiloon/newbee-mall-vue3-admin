#!/bin/bash
npm i npm@6 -g
npm install
rm -rf dist
npm run build:release
