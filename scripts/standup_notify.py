import csv, datetime, os, re, subprocess, requests
from zoneinfo import ZoneInfo

WEBHOOK_URL = os.environ["TEAMS_WEBHOOK_URL"]
ROSTER_PATH = "data/roster.csv"
UPDATES_PATH = "data/updates.csv"
ARCHIVE_PATH = "data/updates_archive.csv"

def read_roster():
    with open(ROSTER_PATH, newline="") as f:
        return list(csv.DictReader(f))

def git_blame_authors(path):
    output = subprocess.run(
        ["git", "blame", "--line-porcelain", "--", path],
        capture_output=True, text=True, check=True,
    ).stdout
    rows, current_email = [], None
    for line in output.split("\n"):
        if line.startswith("author-mail "):
            current_email = line.split("author-mail ", 1)[1].strip("<>")
        elif line.startswith("\t"):
            rows.append((current_email, line[1:]))
    return rows

NOREPLY_RE = re.compile(r"^\d+\+([^@]+)@users\.noreply\.github\.com$")

def match_person(email, roster_by_email, roster_by_username):
    if email in roster_by_email:
        return roster_by_email[email]
    m = NOREPLY_RE.match(email or "")
    if m:
        return roster_by_username.get(m.group(1))
    return None

roster = read_roster()
roster_by_email = {r["email"]: r for r in roster}
roster_by_username = {r["github_username"]: r for r in roster}

now_ist = datetime.datetime.now(ZoneInfo("Asia/Kolkata"))
today_str = now_ist.date().isoformat()
iso_week = now_ist.date().isocalendar()[1]
speaker = roster[(iso_week - 1) % len(roster)]

blamed = git_blame_authors(UPDATES_PATH)
attributed, unmatched = [], []
for email, content in blamed:
    if not content.strip():
        continue
    person = match_person(email, roster_by_email, roster_by_username)
    if person:
        attributed.append({"name": person["name"], "email": email, "update": content.strip()})
    else:
        unmatched.append({"name": email or "unknown", "email": email, "update": content.strip()})

by_name = {a["name"]: a["update"] for a in attributed}
update_summary = "\n\n".join(
    f"**{r['name']}:** {by_name.get(r['name'], '_no update logged_')}"
    for r in roster
)
if unmatched:
    update_summary += "\n\n_Unattributed (git email didn't match roster):_\n" + "\n".join(
        f"- {u['email']}: {u['update']}" for u in unmatched
    )

payload = {
    "speaker_email": speaker["email"],   # used by the flow to resolve real Teams identity
    "update_summary": update_summary,
}

resp = requests.post(WEBHOOK_URL, json=payload)
resp.raise_for_status()

# --- clear + archive, unchanged from before ---
open(UPDATES_PATH, "w").close()
archive_rows = [
    {"date": today_str, "name": a["name"], "email": a["email"], "update": a["update"]}
    for a in (attributed + unmatched)
]
if archive_rows:
    archive_exists = os.path.exists(ARCHIVE_PATH)
    with open(ARCHIVE_PATH, "a", newline="") as f:
        writer = csv.DictWriter(f, fieldnames=["date", "name", "email", "update"])
        if not archive_exists:
            writer.writeheader()
        writer.writerows(archive_rows)