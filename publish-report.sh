#!/bin/sh -l

echo "Hello report"
time=$(date)
echo ::set-output name=time::$time
echo `ls`
cat README.md
