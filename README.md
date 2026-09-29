# 🧱 Brick Breaker x86 MASM

A classic, high-performance **Brick Breaker** arcade game written entirely in native **x86 Assembly (MASM)** using the **Win32 API** and **Windows GDI Graphics Engine**. 

Designed to showcase raw assembly-level programming, this project implements low-level memory management, custom physics, double-buffered visual rendering, dynamic UI controls, and multi-tier gameplay mechanics without relying on external game engines or third-party libraries.

---

## ✨ Features

* **GDI Double-Buffered Rendering Engine:** Eliminates screen tearing and flickering by managing a custom memory Device Context (`CreateCompatibleDC`) for smooth 60 FPS performance.
* **Per-Level High Score Tracking:** Stores separate speedrun records (`BestTimeArray`) for Level 1, Level 2, and Level 3 independently.
* **Dynamic Dropping Power-Up System:** Tracks points scored during active gameplay. Reaching every **75 points** spawns a falling power-up orb from the location of the destroyed brick.
* **Randomized Superpowers:** Catching a dropping orb with the paddle triggers 1 of 3 randomized abilities:
  * 🪩 **Multi-Ball (2 Balls):** Spawns a secondary active ball with independent trajectory physics, wall bounces, and brick collisions.
  * ❤️ **+1 Extra Life:** Instantly grants an extra life to prolong the run.
  * ⏱️ **Time Freeze (-10 Seconds):** Subtractions 10 seconds from your current level completion timer.
* **Multi-Tier Brick Durability:** Interactive brick map structures with multi-hit health states (visually color-coded for visual clarity).
* **Speed Escalation:** Dynamic paddle bounce math that subtly increases ball speed on consecutive hits.
* **Full Game Lifecycle:** Features a complete Title Screen, In-Game HUD, Mid-Game "END GAME" menu routing, Game Over, and Level Victory overlays.

---

## 📐 Architecture & Technical Overview

The project is structured into four specialized assembly source files:

| File | Purpose |
| :--- | :--- |
| `GameVars.inc` | Master header file containing Win32 API function prototypes, structural definitions (`RECT`, `POINT`, `PAINTSTRUCT`), global game state variables, level map arrays, and HUD text buffers. |
| `Main.asm` | Application entry point and orchestrator. Manages the Win32 window creation, button controls, input message loop (`WM_KEYDOWN`, `WM_COMMAND`), and state routing. |
| `RenderGDI.asm` | Graphics pipeline responsible for drawing the background, bricks, paddle, primary ball, cyan multi-ball, magenta power-up orbs, HUD text, and overlay screens. |
| `Physics.asm` | Trajectory calculation loop, boundary detection, brick array collision matrix, power-up orb gravity, superpower allocation logic, and timer calculations. |

---

## 🛠️ How to Build and Run

### Prerequisites
To compile and assemble this project on Windows, you will need:
* **MASM32 SDK** or **Microsoft Visual Studio** (with C++ and x86 MASM tools `ml.exe` and `link.exe`).

# 🔨 Assembly & Linking Instructions

1. Open your terminal or **Developer Command Prompt for Visual Studio**.
2. Navigate to the project directory:
   ```cmd
   cd C:\path\to\your\project

### 1. Assemble the source code into a COFF object file:
```cmd
ml /c /coff Main.asm
link /SUBSYSTEM:WINDOWS Main.obj
Main.exe


## 🎮 Controls & Inputs
| Input / Control | Action |
| :--- | :--- |
| **`LEFT ARROW`** | Shift paddle left |
| **`RIGHT ARROW`** | Shift paddle right |
| **`SPACEBAR`** | Launch ball / Start game / Restart after Game Over |
| **`START GAME` Button** | Begin playing from Title Screen |
| **`CHANGE LEVEL` Button** | Cycle through Level 1, Level 2, and Level 3 |
| **`END GAME` Button** | Abort active match and return to Title Screen |


