# Usage:
#
#    python process-data.py < data-raw.csv > data.csv

import csv
from datetime import datetime, date
import sys

quarters = list(csv.DictReader(open("quarters.csv")))
for q in quarters:
    for a in ["start", "end", "start_prev_sunday"]:
        q[a] = date.fromisoformat(q[a])

def locate_quarter(timestamp):
    # Return (quarter, week number) or (None, None)
    d = timestamp.date()
    l = [q for q in quarters if q["start"] <= d <= q["end"]]
    if len(l) > 0:
        q = l[0]
        week_num = (d - q["start_prev_sunday"]).days//7 + 1
        if q["thanksgiving_week_num"] != "":
            if week_num == int(q["thanksgiving_week_num"]):
                return None, None
            elif week_num > int(q["thanksgiving_week_num"]):
                week_num -= 1
        return q, week_num
    else:
        return None, None

outfile = csv.writer(sys.stdout)
outfile.writerow(
    [
        "location",
        "timestamp",
        "academic_year",
        "quarter",
        "quarter_week_num",
        "weekday",
        "hour",
        "count",
        "percentage"
    ]
)

for r in csv.DictReader(sys.stdin):
    ts = datetime.fromisoformat(r["timestamp"])
    q, qwn = locate_quarter(ts)
    if q == None:
        continue
    outfile.writerow(
        [
            r["location"],
            r["timestamp"],
            q["academic_year"],
            q["name"],
            qwn,
            ts.strftime("%a"),
            ts.hour,
            r["count"],
            r["percentage"]
        ]
    )
