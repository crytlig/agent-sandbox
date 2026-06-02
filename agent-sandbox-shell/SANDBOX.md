# Sandbox Browser Automation Setup

This documents how to set up interactive browser access inside the Docker sandbox, enabling coding agents to pause for manual steps like MFA login.

## Environment

- OS: Ubuntu 25.10 (arm64)
- Node.js: v20
- Python: 3.13

## Installed Components

| Component          | Purpose                                    |
| ------------------ | ------------------------------------------ |
| Playwright (npm)   | Browser automation                         |
| Chromium 148       | Browser (headless + headed builds)         |
| Xvfb               | Virtual display server                     |
| x11vnc             | VNC server for the virtual display         |
| noVNC + websockify | Browser-accessible VNC client on port 6080 |

Install commands:

```bash
npm install playwright
npx playwright install chromium --with-deps
sudo apt-get install -y x11vnc novnc
```

## Starting the Stack

Run these in order:

```bash
# 1. Start virtual display
Xvfb :99 -screen 0 1280x900x24 &

# 2. Start VNC server (no password, localhost only)
DISPLAY=:99 x11vnc -display :99 -nopw -listen localhost -xkb -forever -shared -bg -o /tmp/x11vnc.log

# 3. Start noVNC websocket proxy
websockify --web /usr/share/novnc/ 6080 localhost:5900 &

# 4. Launch Chromium headed
DISPLAY=:99 /home/agent/.cache/ms-playwright/chromium-1223/chrome-linux/chrome \
  --no-sandbox \
  --disable-dev-shm-usage \
  --disable-gpu \
  --window-size=1280,900 \
  "https://example.com" &
```

## Accessing the Browser from the Host

Publish the sandbox ports using the sbx CLI:

```bash
sbx ports --publish 6080 <sandbox-name>
```

Then open the noVNC URL in your host browser — use `127.0.0.1`, not `localhost`:

```
http://127.0.0.1:<mapped-port>/vnc.html?autoconnect=true&resize=scale
```

Port 5900 (raw VNC) is also exposed if you prefer a native VNC client.

## Agent + Manual Intervention Pattern

For flows that require MFA or other manual steps:

1. Agent launches Chromium headed and navigates to the login page.
2. Agent pauses (e.g., `page.pause()` in Playwright or a manual `readline` prompt).
3. User opens the noVNC URL, completes MFA/login in the browser.
4. User signals the agent to continue (e.g., press Enter in the terminal).
5. Agent resumes automation from the authenticated session.

## Notes

- dbus errors in Chrome logs (`Failed to connect to socket /run/dbus/system_bus_socket`) are harmless in a container and can be ignored.
- Ubuntu 25.10 is not officially supported by Playwright; it falls back to the `ubuntu24.04-arm64` build, which works fine.
- Chromium is installed at: `~/.cache/ms-playwright/chromium-1223/chrome-linux/chrome`
