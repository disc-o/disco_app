# disco_app

A Decentralized Self-contained OAuth 2.0 Service.

## Getting Started

```bash
cd ~/Android/Sdk/platform-tools
./adb forward tcp:3000 tcp:3000
./adb reverse tcp:3001 tcp:3001
lt --subdomain disco-app --port 3000
```

Then fire up `disco_server` and `disco_client`.

Enter `localhost:3002`, get the UID from that page.
Change *Proxy URL* to `https://disco-app.localtunnel.me`, click *Update*
Click *Start server* and then click *Connect remote*