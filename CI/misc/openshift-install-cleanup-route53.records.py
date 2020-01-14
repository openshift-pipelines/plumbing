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
#
# Python script using the boto library to delete route53 zones and records,
# cause the awscli seems too sucky with deletion (you need to pass a big xml
# blob to it)
#
# You need the credentials setup with whatever means in ~/.aws or via env
# variables.
#
# After the 'reaper' has reaped our openshift install in the aws account, it
# forget to delete some A records, so the reinstall fails :((
# let's be helpful and do it for the reaper....
#

import argparse
import sys

import boto

# Shoudl be static
DEVCLUSTER_DNS_ZONE = 'devcluster.openshift.com.'


class NoGoZoneIsANogo(Exception):
    pass


def delete_hosted_zone(zonename):
    zone = route53.get_zone(zonename)
    if not zone:
        print("Could not find " + zonename)
        return
    records = zone.get_records()

    print("Deleting zone: " + zonename)
    for rec in records:
        if rec.type in ('NS', 'SOA'):
            continue
        zone.delete_record(rec)
        print("\tdeleted record " + rec.name)

    print("Zone " + zonename + " has been deleted.")
    zone.delete()


def delete_record(zonename, recordname):
    if not zonename.endswith("."):
        zonename += "."
    if not recordname.endswith("."):
        recordname += "."

    zone = route53.get_zone(zonename)
    if not zone:
        raise NoGoZoneIsANogo("Could not find zone for " + zonename)

    record = zone.get_a(recordname)
    if not record:
        print("Could not find record " + recordname)
        return

    print("Record " + record.name + " has been deleted.")
    zone.delete_a(record.name)


if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument(
        '-f',
        action='store_true',
        default=False,
        dest='force',
        help='Force install')

    parser.add_argument('clustername')
    args = parser.parse_args()
    route53 = boto.connect_route53()

    zonename = args.clustername + '.' + DEVCLUSTER_DNS_ZONE

    if not args.force:
        print("I am about to delete the zone: " + zonename)
        reply = input(
            "Just out of sanity check, can you please confirm that's what you want [Ny]: "
        )
        if not reply or reply.lower() != 'y':
            sys.exit(0)

    delete_hosted_zone(zonename)
    delete_record(DEVCLUSTER_DNS_ZONE, "api." + zonename)
    delete_record(DEVCLUSTER_DNS_ZONE, "\\052.apps." + zonename)
