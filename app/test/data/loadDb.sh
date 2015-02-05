#!/bin/bash

ls -1 *.json | sed 's/.json$//' | while read col; do
    mongoimport -d cbase -c $col --jsonArray < $col.json;
done