#!/usr/bin/env bash
cd "${TRAVIS_BUILD_DIR}"

mix coveralls.travis
