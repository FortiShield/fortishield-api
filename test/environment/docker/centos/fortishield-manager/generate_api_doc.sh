#!/usr/bin/env bash
/var/ossec/framework/python/bin/python3 ./generate_rst.py /fortishield-documentation/source/user-manual/api/reference.rst
cd /fortishield-documentation
make html
