# Setup Tutorial

Push this repo to GitHub under `Distendo/UUI` and use it in Roblox.

## Step 1 — Create the repo on GitHub

1. Go to https://github.com/new
2. **Repository name:** `UUI`
3. **Description:** `UUI - UU's UI Library`
4. Leave it **Public**
5. **Do NOT** check "Add a README" or ".gitignore" or "license" (we already have them)
6. Click **Create repository**

## Step 2 — Push from terminal

On the page that appears, look under **"…or push an existing repository from the command line"** and run those two commands:

```bash
git remote add origin https://github.com/Distendo/UUI.git
git branch -M main
git push -u origin main
```

It will ask for your GitHub username and password — use a **Personal Access Token** instead of your password:

1. Go to https://github.com/settings/tokens
2. Click **Generate new token (classic)**
3. Check `repo` scope
4. Copy the token
5. Paste it when prompted for password

## Step 3 — Use in Roblox

After pushing, your raw URL will be:

```
https://raw.githubusercontent.com/Distendo/UUI/main/UUI.lua
```

Test it in Roblox:

```lua
local UI = loadstring(game:HttpGet("https://raw.githubusercontent.com/Distendo/UUI/main/UUI.lua"))()

local Window = UI:CreateWindow("My Hub")

local Tab = Window:CreateTab("Main")

Tab:CreateButton("Hello!", function()
    print("UUI works!")
end)
```

## Tips

- **Caching:** GitHub caches raw files. After pushing an update, wait ~30 seconds or append `?t=123` to bypass: `game:HttpGet("https://raw.githubusercontent.com/Distendo/UUI/main/UUI.lua?t="..tick())`
- **Private repo:** If you make it private, use `game:HttpGet("https://raw.githubusercontent.com/Distendo/UUI/main/UUI.lua?token=YOUR_TOKEN")`
- **Updates:** Just `git push` new commits — users re-loading via `loadstring` will get the latest version automatically.
