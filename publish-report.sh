#!/bin/sh -l

echo "Hello report"
time=$(date)
echo ::set-output name=time::$time
cat /github/workspace/README.md
