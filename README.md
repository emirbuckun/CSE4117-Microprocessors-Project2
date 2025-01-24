# CSE4117-Microprocessors-Project2

## Project Structure

### Source Files
- `src/assembler.c`: C program to assemble the assembly code into machine code.
- `src/vga.sv`: SystemVerilog module for VGA display.
- `src/timer.sv`: SystemVerilog module for a timer.
- `src/mammal.sv`: SystemVerilog module for the Mammal CPU.
- `src/main.sv`: SystemVerilog module for the main system integration.
- `src/keyboard.sv`: SystemVerilog module for keyboard input handling.
- `src/assembly.asm`: Assembly code for the project.

### Data Files
- `src/ram.dat`: Initial memory content for the system.

## Description

This project involves the design and implementation of a microprocessor system with various components including a CPU, VGA display, timer, and keyboard input. The system is programmed using assembly language and the components are integrated using SystemVerilog.

### Assembler
The `assembler.c` file reads the assembly code from `assembly.asm`, converts it into machine code, and writes the output to `ram.dat`.

### VGA Display
The `vga.sv` module handles the VGA display logic, including generating synchronization signals and displaying the spaceship and planet bitmaps.

### Timer
The `timer.sv` module implements a timer that generates interrupts at specified intervals.

### Mammal CPU
The `mammal.sv` module is the main CPU of the system, handling instruction execution, interrupts, and memory access.

### Main System
The `main.sv` module integrates all the components, handling memory mapping, interrupt requests, and data multiplexing.

### Keyboard Input
The `keyboard.sv` module handles keyboard input, generating interrupts and providing scan codes to the CPU.

### Assembly Code
The `assembly.asm` file contains the assembly code that initializes the system, handles interrupts, and controls the movement of the spaceship and planet.

## How to Run

1. Compile the assembler:
   ```sh
   gcc -o assembler src/assembler.c
   ```

2. Run the assembler to generate `ram.dat`:
   ```sh
   ./assembler
   ```

3. Load the `ram.dat` file into the memory of the system and simulate the SystemVerilog modules using your preferred simulation tool.

4. Observe the VGA display and interact with the system using the keyboard.
