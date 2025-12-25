# Godot Editor Screenshot to Discord Webhook

A lightweight **Godot Engine 4** plugin designed for mobile and desktop developers to quickly share their editor progress. Capture your current editor view and send it to a Discord channel with a custom title and description in one click.

## ✨ Features
- **Clean Captures**: Automatically hides the plugin button and input dialog before taking the screenshot.
- **Rich Embeds**: Sends images inside a clean Discord Embed with timestamps and Godot branding.
- **Custom Metadata**: Includes a GUI to add a title and detailed notes to your progress report.
- **Visual Feedback**: Real-time status updates on the button (Sending... -> Success! / Failed!).

## 🚀 Setup Instructions

1. **Download/Clone** this repository.
2. Move the `addons/editor_screenshot` folder into your Godot project's `res://addons/` directory.
3. Open the plugin script: `addons/editor_screenshot/screenshot_tool.gd`.
4. Replace `YOUR_DISCORD_WEBHOOK_URL_HERE` with your actual Discord Webhook URL.
5. Go to **Project Settings > Plugins** and check the **Enabled** box for "Editor Screenshot to Discord".

## ⚠️ Security Warning
**Do not commit your real Webhook URL to public repositories!** If you plan to keep this repo public, consider leaving the URL field empty in your commits or using an environment variable if on Desktop.

## 📱 Mobile Users (Android/iOS)
Ensure that the **Internet Permission** is enabled in your Export settings if you intend to use this while testing exports, though this plugin is primarily designed to run within the **Godot Editor** itself.

## 📄 License
This project is licensed under the MIT License.