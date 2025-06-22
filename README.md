# Flappy Bird FPGA Game – COMPSYS 305 Mini Project

This project is a hardware-accelerated implementation of **Flappy Bird** on an FPGA board, developed for the COMPSYS 305 course at the University of Auckland.  
It uses VHDL and VGA output to simulate the game in real time on a DE0-CV development board.

## 📺 Overview

- **Platform:** DE0-CV FPGA board (Cyclone V)
- **Language:** VHDL
- **Display:** 640x480 VGA
- **Input:** PS/2 Mouse (left click to flap)
- **Output:** VGA monitor (bird, pipes, text, background)

---

## Features

- Real-time Flappy Bird animation with pixel-perfect VGA rendering
- Mouse-controlled vertical bird movement (left click to flap)
- Scrolling pipes with randomized gaps
- Collision detection (pipes vs. bird)
- Gift system: collecting gifts increases life count
- Layered display: background, pipes, bird, and score/text
- Sprite rendering from `.mif` files using dual-port ROMs

---

## Project Structure

| File / Folder         | Description |
|-----------------------|-------------|
| `Display_Control.vhd` | Combines all sprite layers (background, pipes, bird, text) for VGA output |
| `poop_control.vhd`    | Handles bird movement logic and FSM based on mouse input |
| `mouse.vhd`           | PS/2 protocol handler for receiving mouse data |
| `Game_Control.vhd`    | Manages game states (start, pause, running, collision, etc.) |
| `pipe.vhd` / `pipe_gen.vhd` | Generates pipes and controls scrolling |
| `text_gen.vhd`        | Displays current score or messages (e.g., “GAME OVER”) |
| `altsyncram` modules  | Dual-port ROMs for sprite memory (background, bird, etc.) |
| `.mif` files          | Memory initialization files containing image data (12-bit color: R4:G4:B4) |

---

##  Input Device

- **Mouse Input:**
  - Left click triggers a flap (rising motion)
  - Data is read through `mouse.vhd` via PS/2 protocol
  - Mouse streaming mode initialized via command `F4`

---

##  Output

- **VGA 640x480 60Hz**
  - Background, bird, pipes, text rendered in sync with `vert_sync` and `horiz_sync`
  - 12-bit RGB output (4 bits per channel)

---

## Finite State Machines

- `falling_ball` / `poop_control`: IDLE, RUNNING, PAUSED states
- `Game_Control`: FSM handling game start, play, game over, reset
- VGA sync and display timing controlled with counters

---

## How to Build and Run

1. Open Quartus Prime and load the `.qpf` project
2. Compile the top-level design (e.g., `flappy_bird.vhd`)
3. Load `.sof` file to DE0-CV board via USB Blaster
4. Connect a VGA monitor and PS/2 mouse to the board
5. Watch the game run in real time!

---

##  Tools Used

- Intel Quartus Prime
- ModelSim / QuestaSim for simulation
- DE0-CV (Cyclone V) development board
- `.mif` generator (for sprite images)
- Paint.NET / GIMP (for image formatting to `.bmp`)

---

## Special Notes

- This project references structural guidance from a senior’s `graphics_controller.vhd`, with custom FSM logic and sprite layering added.
- System modularization (e.g., `Display_Control`, `poop_control`, `Game_Control`) allows for flexible game logic upgrades.
- Background upgraded from 4-bit/8-bit to **12-bit color (R4:G4:B4)** for enhanced visuals.

---

## Screenshots (optional)

> _Insert screenshots or photos of the game running on the VGA screen_

---

## Course

> COMPSYS 305 – Digital Systems Design  
> The University of Auckland – Semester 1, 2025  
> Instructor: Dr. Morteza Biglari-Abhari / Dr. Maryam Hemmati

---

## Contact

Developed by [Ava Lee](https://github.com/avalee0215)  
For portfolio/demo use only. Please do not copy without permission.
