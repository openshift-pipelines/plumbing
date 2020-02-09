#!/usr/bin/env python3
# -*- coding: utf-8 -*-
# Author: Chmouel Boudjnah <chmouel@chmouel.com>
#
# Licensed under the Apache License, Version 2.0 (the "License"); you may
# not use this file except in compliance with the License. You may obtain
# a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
# WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
# License for the specific language governing permissions and limitations
# under the License.
import glob
import os.path
import sys

import jinja2

BASE_DIR = len(sys.argv) > 0 and sys.argv[1] or "templates"
SCRIPT_TYPE = ['py', 'sh']

loader = jinja2.FileSystemLoader(searchpath=BASE_DIR)
tenv = jinja2.Environment(loader=loader)

for tyaml in glob.glob(f"{BASE_DIR}/*.yaml"):
    base = os.path.basename(tyaml)
    template = tenv.get_template(base)

    sansext = os.path.splitext(tyaml)[0]
    script_file = None
    for stype in SCRIPT_TYPE:
        joined = f"{sansext}.{stype}"
        if os.path.exists(joined):
            script_file = joined

    if not script_file:
        print(f"No template file found for: {tyaml}")
        continue

    output = template.render(script_file=open(script_file).read())
    if output[0:3] != "---":
        output = f"--- \n{output}"
    print(output)
