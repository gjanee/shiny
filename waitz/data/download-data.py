# Usage:
#
#    python download-data.py start end > data-new.csv
#    sed 1d data-new.csv >> data-raw.csv
#
# The start and end dates are inclusive.
#
# This script always writes a header record.  If using it to
# incrementally add data, then remove the first line using sed as
# indicated above.
#
# N.B.: this script uses an API call, /counts, that seems to be
# deprecated.  Or at least, the call is no longer documented (but it
# still works as of this writing).

import csv
import sys

import occuspace

start, end = sys.argv[1:3]

locations = list(csv.DictReader(open("locations.csv")))

outfile = csv.writer(sys.stdout)
outfile.writerow(["location", "timestamp", "count", "percentage"])

for loc in locations:
    print(f"Downloading {loc['name']}...", file=sys.stderr)
    r = occuspace.get(
        f"/locations/{loc['id']}/counts",
        params={"start": start, "end": end}
    )
    if "message" in r and r["message"] == "RANGE MISSING":
        # No data for location
        continue
    for cnt in r["data"]["counts"]:
        outfile.writerow(
            [
                loc["name"],
                cnt["normalizedDate"] + " " + cnt["normalizedTime"],
                cnt["count"],
                cnt["percentage"]
            ]
        )
