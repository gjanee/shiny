# Usage:
#
#    python download-locations.py > locations.csv

from collections import namedtuple
import csv
import sys

import occuspace

indentation = "&nbsp;&nbsp;&nbsp;&nbsp;"

Location = namedtuple(
    "Location",
    "id parent_id name capacity earliest_count is_active"
)

locations = [
    Location(
        loc["id"],
        loc["parentId"],
        loc["name"],
        loc["capacity"],
        loc["earliestCount"],
        loc["isActive"]
    )
    for loc in occuspace.get("/locations")["data"]
]

outfile = csv.writer(sys.stdout)
outfile.writerow(
    [
        "id",
        "parent_id",
        "name",
        "name_indented",
        "capacity",
        "earliest_count",
        "is_active"
    ]
)

def walk(parent, level):
    outfile.writerow(
        [
            parent.id,
            parent.parent_id,
            parent.name,
            indentation*level + parent.name,
            parent.capacity,
            parent.earliest_count,
            parent.is_active
        ]
    )
    children = sorted(
        (loc for loc in locations if loc.parent_id == parent.id),
        key=lambda loc: loc.name
    )
    for c in children:
        walk(c, level+1)

walk([loc for loc in locations if loc.parent_id == None][0], 0)
