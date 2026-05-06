# 🚀 EzRES - Drk External Integration

A professional camera resolution controller for Roblox, secured with the **Drk External Key System** and protected by hCaptcha.

---

## 🔑 How to Get Started

1. **Get your License Key:**  
   Visit our [License Portal](https://drk.qzz.io/DrkExternal-Key/) and complete the hCaptcha to generate your free 12-hour key.

2. **Execute the Script:**  
   Copy and paste the following command into your favorite Roblox executor:

   ```lua
   loadstring(game:HttpGet("https://raw.githubusercontent.com/ltnproject/ezres/main/main.lua"))()
   ```

3. **Login:**  
   Enter your key into the GUI that appears. Your key will be locked to your HWID on the first successful login.

---

## ✨ Features
- **HWID Protection:** Keys are bound to your device.
- **Auto-Expiration:** 12-hour license keys for security.
- **hCaptcha Secured:** Protection against automated bot abuse.
- **Hidden Payload:** The core logic is securely fetched from Salting.io only after verification.
- **Aspect Ratio Control:** Smoothly adjust your camera resolution/aspect ratio in-realtime.

---

## 🛠️ Security Architecture
This project uses a multi-layered security approach:
- **Frontend:** hCaptcha + Salting.io Bridge (hides Firebase secrets).
- **Backend:** Firebase Realtime Database for license management.
- **Execution:** Secure loader with Base64 payload decryption.

---
*Developed with ❤️ by the Drk External Team*
