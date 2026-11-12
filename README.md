# Stoat Group Chat Leaver

A small PowerShell script that leaves a Stoat group chat through the API. It is useful when the app doesn't show a "Leave" button for a group.

## Requirements

- Windows with PowerShell 5.1 or newer (already included in Windows 10 and 11)
- Your Stoat session token
- The ID of the group chat you want to leave

## Usage

Open PowerShell in the folder containing `leave-group.ps1` and run:

```powershell
powershell -ExecutionPolicy Bypass -File .\leave-group.ps1
```

The script asks for:

1. **X-Session-Token**: your account's session token (input is hidden)
2. **Group chat ID**: the ID of the group to leave
3. **Leave silently?**: `y` skips the "user left" message in the group, `N` or Enter lets the group see it

It then shows the group's name and asks you to confirm. On success it prints a green message:

```
Success! You left '<group name>'.
```

Errors are printed in red.

## How to find your group chat ID

- **Stoat app:** turn on Developer Mode in the app's settings, then right-click the group and choose Copy ID. The exact menu wording may differ by version.
- **API:** `GET /users/dms` returns your DMs and groups. Groups have `"channel_type": "Group"` and their ID in `_id`.

## How to get your session token

The token comes from your logged-in session. One way is to read the `x-session-token` header from a request in your browser's developer tools (Network tab) while using the Stoat web app. Treat it like a password.

## What it does

1. Fetches the channel with `GET /channels/{id}`.
2. Checks that it is a group chat. If the ID is anything else, such as a server channel, it stops without changing anything, because the same request would delete a server channel.
3. Asks you to confirm.
4. Sends `DELETE /channels/{id}` (with `?leave_silently=true` if you chose silent) to leave the group.

## Configuration

The API address is set at the top of the script:

```powershell
$ApiBase = "https://api.stoat.chat"
```

Change it if you use a self-hosted instance or Stoat's API address changes.

## Troubleshooting

| Message | Likely cause |
| --- | --- |
| HTTP 401 / "token looks invalid" | The token is wrong or expired. Get a fresh one. |
| HTTP 404 / "Group chat not found" | The ID is wrong, or you've already left the group. |
| "not a group chat" | The ID belongs to a DM or server channel. Nothing was changed. |
| Connection or DNS error | `$ApiBase` is wrong for your instance. |
| "running scripts is disabled" | Use the `-ExecutionPolicy Bypass` command shown above. |

## Security notes

- Your session token gives full access to your account. Never share it or post it in chat or screenshots.
- The script sends the token only to the API address in `$ApiBase`, and it doesn't save it anywhere.
- If your token has been exposed, log that session out in Stoat's settings to invalidate it.
- Leaving a group can't be undone. You can only rejoin if someone invites you back.
