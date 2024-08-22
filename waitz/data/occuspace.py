# The Occuspace API is documented at https://occuspace.io/api.

import requests

base_url = "https://api.occuspace.io/v1"
api_token = open("TOKEN").read().strip()
headers = {"Authorization": "Bearer " + api_token}

def get(url, params=None):
    r = requests.get(base_url + url, params=params, headers=headers)
    assert r.status_code == 200, f"received status code {r.status_code}"
    return r.json()
