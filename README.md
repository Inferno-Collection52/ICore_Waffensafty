# ICore_Waffensafty

Description
- `ICore_Waffensafty` Adds firing modes to your choice of weapons, as well as more realistic reloading (including disabling automatic reloading), constant flashlights (staying on even when the weapon is not aimed), more blood on injuries, and limping after an injury.

Features
- Alternate fire modes for selected weapons
- More realistic reloading (option to disable automatic reload)
- Persistent flashlight behavior (flashlight stays on even when not aiming)
- Increased blood effects and limping after injury

Installation
- Copy the `ICore_Waffensafty` folder into your server's `resources` directory.
- Add the following line to your `server.cfg` (or resource start list) and restart the server:

```cfg
start ICore_Waffensafty
```

Configuration
- Edit `config.lua` to adjust behavior and UI settings.

Usage / Testing
- Start the resource, join the server, equip a weapon and check the NUI UI in `nui.html`.
- For quick testing: restart the server and equip a weapon in-game. Watch the server and client consoles for errors.

Key files
- `client.lua` — client-side logic
- `server.lua` — server-side events
- `config.lua` — configuration options
- `nui.html` — NUI user interface
- `fxmanifest.lua` — resource manifest
- `images/` — graphics and assets

Troubleshooting
- Ensure `start ICore_Waffensafty` is present in your `server.cfg`.
- Check the server console for Lua errors during resource startup.
- If the NUI doesn't load, verify file paths in `fxmanifest.lua` and check the in-game F8 console for browser errors.

Support
- Open an issue or contact the author for help or feature requests.

License
- Use and modify this resource as needed; check the project for any specific license notes.
