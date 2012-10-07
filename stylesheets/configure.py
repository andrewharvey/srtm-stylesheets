#!/usr/bin/env python

# Copyright (c) 2011, Development Seed, Inc.
#               2012, Andrew Harvey <andrew.harvey4@gmail.com>
#               All rights reserved.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are
# met:
#
#     * Redistributions of source code must retain the above copyright
#       notice, this list of conditions and the following disclaimer.
#     * Redistributions in binary form must reproduce the above copyright
#       notice, this list of conditions and the following disclaimer in
#       the documentation and/or other materials provided with the
#       distribution.
#     * Neither the name of the Development Seed, Inc. nor the names of
#       its contributors may be used to endorse or promote products
#       derived from this software without specific prior written
#       permission.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS
# IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED
# TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A
# PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER
# OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
# EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
# PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
# PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
# LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
# NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
# SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.


import json
from sys import path
from os.path import join
import argparse
import shutil

#################################
## argparse

parser = argparse.ArgumentParser(description='Configure an MML file with datasource settings')
parser.add_argument('--host', default='localhost')
parser.add_argument('--port', default='5432')
parser.add_argument('--dbname', default='srtm')
parser.add_argument('--user', default='')
parser.add_argument('--password', default='')

args = parser.parse_args()

#################################
## configure mml

mml = join(path[0], 'contours.mml')

shutil.copyfile( join(path[0], 'contours.template.mml'), mml)

with open(mml, 'r') as f:
  newf = json.loads(f.read())
f.closed

with open(mml, 'w') as f:
  for layer in newf["Layer"]:
    layer["Datasource"]["host"] = args.host
    layer["Datasource"]["port"] = args.port
    layer["Datasource"]["dbname"] = args.dbname
    layer["Datasource"]["user"] = args.user
    layer["Datasource"]["password"] = args.password
  f.write(json.dumps(newf, indent=2))
f.closed

