import os
import json
import requests
from datetime import datetime
import openpyxl  # pip install openpyxl

WEBHOOK_URL = os.environ["TEAMS_WEBHOOK_URL"]
EXCEL_PATH = "data/Standup_Updates.xlsx"
STATE_PATH = "data/rotation_state.json"

def get_next_speaker(roster):
    """Calculates the speaker on a continuous loop regardless of calendar year."""
    state = {"last_index": -1}
    if os.path.exists(STATE_PATH):
        with open(STATE_PATH, "r") as f:
            state = json.load(f)
    
    # Check if today is Monday to advance the speaker
    today = datetime.now()
    # 0 = Monday
    if today.weekday() == 0 or state["last_index"] == -1:
        next_index = (state["last_index"] + 1) % len(roster)
    else:
        next_index = state["last_index"]

    # Save state
    with open(STATE_PATH, "w") as f:
        json.dump({"last_index": next_index, "updated_at": today.isoformat()}, f)

    return roster[next_index]

def read_excel_updates():
    wb = openpyxl.load_workbook(EXCEL_PATH)
    
    # Read Roster
    roster_sheet = wb["Roster"]
    roster = []
    for row in roster_sheet.iter_rows(min_row=2, values_only=True):
        if row[0] is not None:
            roster.append({"order": row[0], "name": row[1], "email": row[2]})
            
    # Read Updates
    updates_sheet = wb["Today"]
    updates = {}
    for row in updates_sheet.iter_rows(min_row=2, values_only=True):
        if row[0] is not None:
            updates[row[1]] = row[2] if row[2] else "_No update logged_"

    return roster, updates

def send_teams_card(speaker, roster, updates):
    """Sends a rich Adaptive Card to MS Teams."""
    
    facts = []
    for member in roster:
        name = member["name"]
        update_text = updates.get(member["email"], "_No update logged_")
        facts.append({"title": name, "value": update_text})

    card_payload = {
        "type": "message",
        "attachments": [
            {
                "contentType": "application/vnd.microsoft.card.adaptive",
                "contentUrl": None,
                "content": {
                    "$schema": "http://adaptivecards.io/schemas/adaptive-card.json",
                    "type": "AdaptiveCard",
                    "version": "1.4",
                    "body": [
                        {
                            "type": "TextBlock",
                            "text": "📢 Daily Standup Reminder (9:00 AM IST)",
                            "weight": "Bolder",
                            "size": "Large",
                            "color": "Accent"
                        },
                        {
                            "type": "Container",
                            "style": "warning",
                            "items": [
                                {
                                    "type": "TextBlock",
                                    "text": f"🎙️ **Weekly Speaker:** {speaker['name']} ({speaker['email']})",
                                    "weight": "Bolder",
                                    "wrap": True
                                },
                                {
                                    "type": "TextBlock",
                                    "text": "Please lead today's meeting and sync on updates!",
                                    "isSubtle": True,
                                    "spacing": "None"
                                }
                            ]
                        },
                        {
                            "type": "TextBlock",
                            "text": "📋 **Today's Team Updates**",
                            "weight": "Bolder",
                            "size": "Medium",
                            "spacing": "Medium"
                        },
                        {
                            "type": "FactSet",
                            "facts": facts
                        }
                    ]
                }
            }
        ]
    }

    response = requests.post(WEBHOOK_URL, json=card_payload)
    response.raise_for_status()

if __name__ == "__main__":
    roster, updates = read_excel_updates()
    speaker = get_next_speaker(roster)
    send_teams_card(speaker, roster, updates)