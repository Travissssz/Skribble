# FPGA Skribble: Hardware-Based Word Drawing & Guessing Game

An interactive, two-player word game developed on the **Basys3 FPGA** platform. This project implements a digital version of "Skribble," featuring real-time mouse-based drawing, dual OLED display management, and automated scoring systems using Verilog.



## System Architecture
The system is built using a modular design in Verilog, integrating various hardware peripherals:

* **FPGA Board**: Xilinx Basys3 (Artix-7).
* **Displays**: Dual Pmod OLED (128x64) screens for independent Drawer and guesser views.
* **Input Devices**: 
    * `USB Mouse`: Integrated via PS/2 protocol for precise 128x64 canvas drawing.
    * `Pushbuttons/Switches`: Used for menu navigation, letter selection, and game configuration.
* **Visual Feedback**: 
    * `On-board LEDs`: Used for countdown timers and status indicators.
    * `7-Segment Display`: Real-time score tracking and timer display.




## Core Features & Logic

### 1. Paint Canvas (Drawer Interface)
A dedicated OLED screen serves as the drawing canvas.
* **Mouse Integration**: Real-time coordinate tracking to map mouse movement to OLED pixel addresses.
* **Brush Controls**: Implemented logic for drawing, erasing, and clearing the canvas using memory-mapped I/O.

### 2. Guessing Engine (Guesser Interface)
A second OLED screen manages the word-guessing logic.
* **Selection Logic**: Users cycle through alphabets using `btnU` and `btnD`, and navigate letter positions using `btnL` and `btnR`.
* **Validation**: Real-time comparison between user input and the hidden word array stored in hardware memory.

### 3. Game State Management
* **Difficulty Scaling**: selectable word banks categorized by complexity.
* **Dynamic Scoring**: Points are calculated based on word difficulty and the speed of the correct guess.
* **Visual Alerts**: The guessed word turns **Green** upon success or **Red** upon failure, utilizing hardware-driven color mapping.




## Technical Challenges Solved

- [x] **PS/2 Mouse Protocol**: Successfully implemented a hardware-level driver to interface a standard USB mouse with the FPGA.
- [x] **Dual OLED Synchronization**: Managed timing constraints to drive two independent SPI-based OLED displays simultaneously from a single clock source.
- [x] **Resource Optimization**: Handled high-workload Verilog modules, optimizing memory usage for the 128x64 drawing bitmask.
- [x] **Debouncing & Timing**: Implemented robust debouncing for all mechanical inputs to ensure smooth menu navigation and letter cycling.

