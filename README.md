# Clay Maze

A maze game written in **x86 assembly (MASM)**. Move through a 10x10 board, collect coins, grab the power-up, dodge the obstacles and reach the goal. The project has two front ends that share the same rules:

- **Clay Maze (GUI)**: a claymorphism web interface (baby blue, dark blue, orange) with a statistics dashboard.
- **Console version**: the original text game, with colours and file saving.

## Run the GUI version

1. Double-click `ClayMaze.exe`.
2. Your browser opens at `http://127.0.0.1:8765/`.
3. Play with **W A S D** or the arrow keys, or use the on-screen buttons.

Keep `ClayMaze.exe` next to the `ui` folder. Press **Quit** (or close the tab and wait two minutes) to stop the game engine.

### How it works

All game logic is in assembly (`ClayMaze/ClayMaze.asm`). The program is also a tiny HTTP server that listens on `127.0.0.1:8765` using Winsock. The web page in `ui/index.html` contains no game rules: it sends key presses to the engine and draws the JSON state the engine returns.

```
key press -> browser -> /api/move?k=d -> assembly engine
                              ^                |
                     draws the board <---- JSON state
```

| Endpoint | Purpose |
| --- | --- |
| `/api/state` | current game state |
| `/api/move?k=w\|a\|s\|d` | move the player |
| `/api/save?s=1..3`, `/api/load?s=1..3` | save to / load from a slot |
| `/api/slots` | contents of the three save slots |
| `/api/history`, `/api/clear` | dashboard statistics, clear history |
| `/api/new`, `/api/quit` | new game, stop the engine |

## Rules

| Symbol | Meaning |
| --- | --- |
| `P` | you (start at the top-left) |
| `G` | goal, +50 points |
| `X` | obstacle, costs 1 life and sends you back to the start |
| `$` | coin, +10 points |
| `@` | power-up, invincible for 5 moves |

You have 3 lives. The game ends when you reach the goal or lose all lives.

## File handling

All files are written next to `ClayMaze.exe`.

| File | Content |
| --- | --- |
| `highscore.dat` | best score (4 bytes) |
| `history.dat` | every finished game: score, moves, result (up to 500) |
| `savegame1.dat` to `savegame3.dat` | three save slots (full game state) |

When a game that was loaded from a slot ends, that slot is deleted, because the save no longer leads anywhere. The dashboard reads `history.dat` and shows games played, wins, losses, win rate, best and average score, total moves, a score chart and the recent games.

## Console version

`Console_Game_Project/` is a Visual Studio solution that uses the Irvine32 library.

1. Install the Irvine32 library to `C:\Irvine`.
2. Open `Console_Game_Project/Console_Game_Project.sln` in Visual Studio (Debug, x86) and press Ctrl+F5.

Controls: W/A/S/D move, F saves, L loads, Q quits. It keeps a single save in `savegame.dat` and the best score in `highscore.dat`, both in the working folder.

## Build the GUI version from source

Requires Visual Studio with the C++ desktop workload (MASM and the Windows SDK).

```powershell
.\build.ps1
```

This assembles `ClayMaze/ClayMaze.asm` and links `ClayMaze.exe` against `kernel32`, `shell32` and `ws2_32`.

## Project layout

```
ClayMaze/                 assembly engine + web server
ui/index.html             claymorphism interface and dashboard
Console_Game_Project/     console version (Visual Studio solution)
build.ps1                 builds ClayMaze.exe
ClayMaze.exe              prebuilt GUI version
```
