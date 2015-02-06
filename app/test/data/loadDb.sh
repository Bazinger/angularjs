#!/bin/bash

ls -1 *.json | sed 's/.json$//' | while read col; do
    mongo cbase --eval "db.${col}.drop()"
    mongoimport -d cbase -c $col --jsonArray < $col.json;
done