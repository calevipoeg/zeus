#!/usr/bin/env bash

rm ./*.gem
gem build zeus.gemspec
gem push zeus-*

