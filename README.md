<div align="center">

<img src="https://capsule-render.vercel.app/api?type=waving&height=190&color=0:05080D,45:0066FF,100:00D4FF&text=SzCore+Medical&fontSize=42&fontColor=FFFFFF&animation=fadeIn&fontAlignY=38&desc=SzCore+Framework+%E2%80%A2+Character+%26+Medical&descAlignY=60&descSize=16" width="100%" alt="SzCore Medical" />

<img src="https://readme-typing-svg.demolab.com?font=Orbitron&weight=700&size=21&duration=2500&pause=850&color=00D4FF&center=true&vCenter=true&width=720&height=52&lines=Character+%26+Medical;Modular+%E2%80%A2+Server-Authoritative+%E2%80%A2+Developer+First" alt="SzCore Medical animated headline" />

<p><b>Medical/death foundation for injuries, bleeding, pain, last stand, death, EMS treatment, revive and hospital respawn.</b></p>

<p>
  <img src="https://img.shields.io/badge/SzCore-v1.4.0--rc1-8B5CF6?style=for-the-badge" alt="Version">
  <img src="https://img.shields.io/badge/Type-Character+%26+Medical-00D4FF?style=for-the-badge" alt="Type">
  <img src="https://img.shields.io/badge/FiveM-Resource-F40552?style=for-the-badge&logo=fivem&logoColor=white" alt="FiveM">
  <img src="https://img.shields.io/badge/Lua-5.4-2C2D72?style=for-the-badge&logo=lua&logoColor=white" alt="Lua">
</p>

<p>
<a href="https://github.com/Szilko121/szcore_death/stargazers"><img src="https://img.shields.io/github/stars/Szilko121/szcore_death?style=flat-square&logo=github&color=00D4FF" alt="Stars"></a>
<a href="https://github.com/Szilko121/szcore_death/issues"><img src="https://img.shields.io/github/issues/Szilko121/szcore_death?style=flat-square&logo=github&color=EF4444" alt="Issues"></a>
<img src="https://img.shields.io/github/last-commit/Szilko121/szcore_death?style=flat-square&logo=github&color=22C55E" alt="Last commit">
</p>

<p><a href="https://github.com/Szilko121/SzCore-Framework"><b>Framework</b></a> • <a href="https://github.com/Szilko121/SzCore-Framework/tree/main/docs"><b>Docs</b></a> • <a href="https://github.com/Szilko121/SzCore-Recipe"><b>Recipe</b></a> • <a href="https://github.com/Szilko121/szcore_death/issues"><b>Issues</b></a></p>
</div>

---

## 🚀 Overview

Medical/death foundation for injuries, bleeding, pain, last stand, death, EMS treatment, revive and hospital respawn.

> Medical state is persisted through SzCore metadata and treatment permissions are checked server-side.

## ✨ Highlights

| | Capability |
|---:|---|
| ⚡ | **Body-part injury tracking** |
| 🧩 | **Bleeding and pain state** |
| 🛡️ | **Last stand and death lifecycle** |
| 💾 | **EMS status/treatment/revive flows** |
| 🎯 | **Hospital respawn and fees** |
| 🔌 | **Medical items and EMS alerts** |

## 📦 Installation

**Dependencies:** `szcore`, `szcore_ui`, `szcore_inventory`, `szcore_status`

```bash
git clone https://github.com/Szilko121/szcore_death.git "resources/[szcore]/szcore_death"
```

```cfg
ensure szcore_death
```

For a complete installation use **[SzCore-Recipe](https://github.com/Szilko121/SzCore-Recipe)**.

## 🔌 API Highlights

`GetMedicalState` · `GetInjuries` · `Heal` · `Revive` · `Kill` · `Respawn`

## 🛡️ Engineering Principles

- Persistent and security-sensitive mutations are validated server-side.
- Feature boundaries stay modular and explicit.
- Client UI/input is not treated as authority.
- Permanent frame loops are used only when FiveM natives require them.
- Performance is measured, not advertised with fixed fake resmon numbers.

## 🧩 Part of SzCore

<div align="center">

[![Framework](https://img.shields.io/badge/SzCore-Framework-00D4FF?style=for-the-badge&logo=github)](https://github.com/Szilko121/SzCore-Framework)
[![Recipe](https://img.shields.io/badge/txAdmin-Recipe-2563EB?style=for-the-badge&logo=github)](https://github.com/Szilko121/SzCore-Recipe)

<br><br><sub>Built by <b>SzCode</b> for the FiveM community.</sub>
<img src="https://capsule-render.vercel.app/api?type=waving&height=90&section=footer&color=0:00D4FF,55:0066FF,100:05080D" width="100%" alt="SzCore footer" />
</div>
