
#!/usr/bin/env python3
# -*- coding: UTF-8 -*-
#
# Copyright (C) 2015-2020, Fortishield Inc.
# Created by Fortishield, Inc. <info@fortishield.com>.
# This program is free software; you can redistribute
# it and/or modify it under the terms of GPLv2

"""This module sends a message to FortishieldDB socket."""

import argparse
import os
import socket
import struct

WDB_SOCKET_PATH = os.path.join('/', 'var', 'ossec', 'queue', 'db', 'wdb')


def get_script_arguments():
    """Get script arguments."""
    parser = argparse.ArgumentParser(usage="usage: %(prog)s [options]",
                                     description="Tool for sending queries to FortishieldDB",  # noqa: E501
                                     formatter_class=argparse.RawTextHelpFormatter)  # noqa: E501

    parser.add_argument('-q', '--query', dest='query',
                        help='Query to send to FortishieldDB', required=True)

    return parser.parse_args()


def send_query_to_wdb(query: str):
    """Send query to FortishieldDB socket.

    :param query: Query to send
    """
    # connect to FortishieldDB socket
    wdb_socket = socket.socket(socket.AF_UNIX, socket.SOCK_STREAM)
    wdb_socket.connect(WDB_SOCKET_PATH)
    # construct message
    encoded_message = query.encode(encoding='utf-8')
    final_message = struct.pack('<I', len(encoded_message)) + encoded_message
    wdb_socket.send(final_message)


if __name__ == '__main__':
    # get script arguments
    arguments = get_script_arguments()
    query = arguments.query
    # send query to FortishieldDB
    send_query_to_wdb(query)
