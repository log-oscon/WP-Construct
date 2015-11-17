#!/bin/bash

find . -name '*.php' -print0 | xargs -0 -n 1 -P 4 php -l