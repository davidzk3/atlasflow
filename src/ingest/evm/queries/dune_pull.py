import os
import time
import json
import requests
from pathlib import Path
from dotenv import load_dotenv

load_dotenv()

DUNE_API_KEY = os.getenv("DUNE_API_KEY")
BASE_URL = "https://api.dune.com/api/v1"
EXPORT_DIR = Path("data/raw/dune")
EXPORT_DIR.mkdir(parents=True, exist_ok=True)

def dune_headers():
    if not DUNE_API_KEY:
        raise RuntimeError("Missing DUNE_API_KEY. Set it in .env")
    return {"X-Dune-API-Key": DUNE_API_KEY}

def execute_query(query_id: int, parameters: dict | None = None) -> str:
    url = f"{BASE_URL}/query/{query_id}/execute"
    payload = {"query_parameters": parameters or {}}
    r = requests.post(url, headers=dune_headers(), json=payload, timeout=60)
    r.raise_for_status()
    return r.json()["execution_id"]

def poll_execution(execution_id: str, sleep_s: int = 3, max_wait_s: int = 300) -> dict:
    url = f"{BASE_URL}/execution/{execution_id}/status"
    waited = 0
    while waited < max_wait_s:
        r = requests.get(url, headers=dune_headers(), timeout=60)
        r.raise_for_status()
        status = r.json()
        state = status.get("state")
        if state in ("QUERY_STATE_COMPLETED", "QUERY_STATE_FAILED", "QUERY_STATE_CANCELLED"):
            return status
        time.sleep(sleep_s)
        waited += sleep_s
    raise TimeoutError(f"Timed out waiting for Dune execution {execution_id}")

def fetch_results_csv(execution_id: str) -> str:
    url = f"{BASE_URL}/execution/{execution_id}/results/csv"
    r = requests.get(url, headers=dune_headers(), timeout=120)
    r.raise_for_status()
    return r.text

def export_csv(name: str, csv_text: str):
    out = EXPORT_DIR / f"{name}.csv"
    out.write_text(csv_text, encoding="utf-8")
    print(f"Saved: {out}")

def main():
    # Placeholder query ids: you will replace these with your own Dune query IDs
    queries = {
        "evm_uniswap_swaps_eth_arb": 0000000,
        "evm_uniswap_liquidity_events_eth_arb": 0000000,
        "evm_across_bridge_flows_eth_arb": 0000000,
        "evm_stargate_bridge_flows_multi": 0000000,
    }

    for name, qid in queries.items():
        if qid == 0:
            print(f"Skipping {name}: query id not set yet")
            continue
        print(f"Running {name} (query {qid})...")
        exec_id = execute_query(qid)
        status = poll_execution(exec_id)
        if status.get("state") != "QUERY_STATE_COMPLETED":
            raise RuntimeError(f"Query failed: {name} -> {json.dumps(status, indent=2)}")
        csv_text = fetch_results_csv(exec_id)
        export_csv(name, csv_text)

if __name__ == "__main__":
    main()
