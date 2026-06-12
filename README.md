<div align="center">
  <img src="icon.ico" alt="SteamDaddy Logo" width="128" height="128" />
  <h1>SteamDaddy</h1>
  <p><b>The Ultimate SteamTools Alternative & Manifest Manager</b></p>
  
  [![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
  [![Platform](https://img.shields.io/badge/platform-windows-lightgray.svg)]()
  [![Discord](https://img.shields.io/badge/Discord-ContraryCDN-5865F2?logo=discord&logoColor=white)](https://discord.gg/XN6YGcUF89)

  <p align="center">
    <a href="#-what-is-steamdaddy">What is it?</a> •
    <a href="#-how-manifests-work">How Manifests Work</a> •
    <a href="#-features--fixes">Features & Fixes</a> •
    <a href="#-how-to-use-steamdaddy">Usage Guide</a> •
    <a href="#-legal--disclaimer">Disclaimer</a>
  </p>
</div>

---

## 🔥 What is SteamDaddy?

**SteamDaddy** is a lightweight, drop-in alternative to SteamTools designed to fix the most frustrating Steam client errors. If you've been plagued by the **"No Internet Connection"** error, **"Purchase Issues,"** or games **not appearing in your library**, SteamDaddy is the definitive solution.

> [!NOTE]
> The "No Internet Connection" error in SteamTools usually occurs because their backend servers are frequently targeted by DDoS attacks, rendering them unable to retrieve game manifests. SteamDaddy resolves this instability entirely by letting you manage manifests locally or via reliable third-party CDNs.

---

## 🧠 How Manifests Work

To download a game, Steam needs a **Manifest**. Think of a manifest as a precise blueprint or a map. It tells the Steam client exactly what data chunks to fetch from the servers to assemble the complete game files. Without a valid manifest, Steam has no idea what to download, which throws connection errors. 

By supplying the correct manifest and its associated `.lua` config, you force Steam to download the game data without needing the SteamTools backend.

> [!TIP]
> We highly recommend sourcing your manifests from reliable Discord communities:
> - **Hubcap:** [discord.gg/hubcapsmanifest](https://discord.gg/hubcapsmanifest)
> - **Contrary:** [discord.gg/XN6YGcUF89](https://discord.gg/XN6YGcUF89)

---

## ✨ Features & Fixes

- **⚡ Overcome Server Outages:** Completely avoid SteamTools server and Fix "No Internet Connection" errors by manually dropping manifests from trusted servers.
- **🛠️ Repair SteamTools:** If your games aren't showing up in your library after applying manifests, or if you're getting a "Purchase Issue" prompt, hit the **Repair SteamTools** option. It automatically fixes corrupted hooks and registry issues.
- **🌐 ContraryCDN API Integration:** Say goodbye to manual drag-and-drop. Link your ContraryCDN API key in Steam Daddy to fetch manifests and `.lua` files instantly just by entering an AppID.
- **📦 Manage Game Updates:** Critical for offline activations (D-Games). Game updates can break your activation. Use the **Manage Game Updates** button to completely block updates for specific games and preserve your activation.
- **🔄 Revert Repair (Fix Steam):** Restore your Steam client back to its vanilla state instantly.

---

## 📥 Download & Installation

Ready to get started? You don't need to compile anything.
1. Head over to the **[Releases](../../releases/latest)** section of this repository.
2. Download the latest `SteamDaddy.exe` release.
3. Run the executable (no installation required). It will automatically detect your Steam installation.

---

## 💻 How to Use SteamDaddy

There are two primary ways to use SteamDaddy: the **Drag & Drop Method** (Manual) and the **API Method** (Automated).

### Method 1: Drag and Drop (Manual Manifests)
If you are downloading manifests directly from communities like Hubcap or Contrary:

1. Obtain the game's manifest and `.lua` file from the Discord server.
2. Launch **SteamDaddy**.
3. Simply **Drag and Drop** the `.lua` and manifest files directly into the SteamDaddy window.
4. SteamDaddy will process them and eliminate the internet connection errors caused by SteamTools outages.

> [!WARNING]
> If games still don't appear in your library or you get a purchase error, right-click inside the app and use the **Repair SteamTools** option.

### Method 2: ContraryCDN API (Automated AppID Fetching)
Skip the manual downloads and fetch manifests directly through SteamDaddy.

1. Join the **Contrary Discord Server:** [discord.gg/XN6YGcUF89](https://discord.gg/XN6YGcUF89)
2. Get verified in the server.
3. Head over to the `#turtle-tool` channel and type `/apikey`.
4. The bot will generate a temporary 7-day API key for you *(Limit: 20 manifest fetches per day)*.
   - *Note: Reseller API keys with higher limits are available; contact server admins for info.*
5. Open **SteamDaddy**, right-click, and select **"Set ContraryCDN API Key"**. Paste your key and save.
6. Now, just right-click, select **"ENTER APPID"**, type the game's AppID, and SteamDaddy will automatically fetch the `.lua` and all available manifests. No drag-and-drop required!

---

## ⚖️ Legal & Disclaimer

> [!IMPORTANT]
> **CRITICAL: READ BEFORE DOWNLOADING OR USING THIS SOFTWARE.**

This repository and its contents are provided strictly for **educational purposes, security research, and digital preservation**. 

1. **No Malicious Use:** This tool is not designed, nor should it be used, to circumvent Digital Rights Management (DRM), facilitate piracy, or violate the Terms of Service of any third-party software vendors or distribution platforms.
2. **User Liability:** The authors and contributors of SteamDaddy assume **zero liability** for any misuse of this software. You are solely responsible for ensuring your use complies with all applicable local, state, and federal laws.
3. **Intellectual Property:** All trademarks and copyrights belong to their respective owners. This project is independent and is not affiliated with, endorsed by, or connected to any corporate entity.

By cloning, compiling, or executing code from this repository, you acknowledge that you understand these terms, agree to them fully, and assume all associated risks.

---

## 📄 License

Distributed under the MIT License. See `LICENSE` for more information.
