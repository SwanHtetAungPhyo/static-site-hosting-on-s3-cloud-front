#!/usr/bin/env bash

aws s3api put-bucket-website --bucket swan-htet-aung-phyo-static-site-101 --website-configuration '
    {
      "IndexDocument": {
        "Suffix": "index.html"
      },
      "ErrorDocument": {
        "Key": "error.html"
      }
    }
'