import csv, datetime, requests, os

WEBHOOK_URL = os.environ["TEAMS_WEBHOOK_URL"]
UPDATES_PATH = "data/updates.csv"
ARCHIVE_PATH = "data/updates_archive.csv"
FIELDS = ["date", "name", "update"]

def read_csv(path):
    with open(path, newline="") as f:
        return list(csv.DictReader(f))

def write_csv(path, rows):
    with open(path, "w", newline="") as f:
        writer = csv.DictWriter(f, fieldnames=FIELDS)
        writer.writeheader()
        writer.writerows(rows)

roster = read_csv("data/roster.csv")
updates = read_csv(UPDATES_PATH)

today = datetime.date.today()
iso_week = today.isocalendar()[1]
speaker = roster[(iso_week - 1) % len(roster)]["name"]
today_str = today.isoformat()

todays_rows = [u for u in updates if u["date"] == today_str]
todays_updates = {u["name"]: u["update"] for u in todays_rows}

update_lines = "\n\n".join(
    f"**{r['name']}:** {todays_updates.get(r['name'], '_no update logged_')}"
    for r in roster
)

card = {
    "type": "message",
    "attachments": [{
        "contentType": "application/vnd.microsoft.card.adaptive",
        "content": {
            "$schema": "http://adaptivecards.io/schemas/adaptive-card.json",
            "type": "AdaptiveCard",
            "version": "1.4",
            "body": [
                {"type": "TextBlock", "text": "Daily standup — 9:00 AM", "weight": "Bolder", "size": "Medium"},
                {"type": "TextBlock", "text": f"🎤 Today's speaker: **{speaker}**", "wrap": True},
                {"type": "TextBlock", "text": update_lines, "wrap": True, "separator": True},
            ],
        },
    }],
}

resp = requests.post(WEBHOOK_URL, json=card)
resp.raise_for_status()

# --- Clear today's rows from the live file, archive them ---
remaining = [u for u in updates if u["date"] != today_str]
write_csv(UPDATES_PATH, remaining)

if todays_rows:
    archive_exists = os.path.exists(ARCHIVE_PATH)
    with open(ARCHIVE_PATH, "a", newline="") as f:
        writer = csv.DictWriter(f, fieldnames=FIELDS)
        if not archive_exists:
            writer.writeheader()
        writer.writerows(todays_rows)