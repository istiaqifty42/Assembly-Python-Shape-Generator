# Menu-Driven NASM Assembly & Python Shape Generator

## Overview
This repository contains a comparative project exploring the architectural differences between high-level and low-level programming. The program algorithmically generates five unique geometric shapes (Concentric Square, Hexagon, Hourglass, Diamond, and Heart) on a 2D Cartesian grid using mathematical loops, parameters, and logic-based boundary conditions. 

## Key Technical Learnings
Building this program required bridging the gap between high-level abstractions and raw hardware execution. Key concepts explored include:
* **System Calls & Hardware Proximity:** Directly interacting with the Linux kernel using `int 0x80` to trigger `sys_read` and `sys_write`, bypassing abstracted functions like Python's `print()`.
* **Manual Memory Management:** Allocating memory addresses in the `.bss` section to handle buffer overflows and using stack operations (`push`/`pop`) to protect CPU registers during execution.
* **Hardware-Level Randomization:** Utilizing CPU clock cycles (`rdtsc`) and modulo division to generate unpredictable parameters, demonstrating how raw hardware behavior contrasts with Python's abstracted Mersenne Twister algorithm.
* **Execution Efficiency:** Analyzing how unpredictable random inputs affect branch prediction and cache behavior at the CPU level.

## Tech Stack
* **Assembly:** 32-bit NASM for Linux
* **Python:** Python 3

<details>
<summary>Execution Examples (click to expand)</summary>

**Concentric Square** (Randomized Colour)
<img width="450" alt="image" src="https://github.com/user-attachments/assets/ce45ab76-b89c-47f5-bc5a-89539e33d41b" />

**Hexagon** (Randomized Size)
<img width="450" alt="image" src="https://github.com/user-attachments/assets/1bd41b53-6cae-4ed3-821a-914d43001d90" />

**Hourglass** (Randomized Location)
<img width="450" alt="image" src="https://github.com/user-attachments/assets/7b9c20db-23f2-4c96-b960-09ea93e026be" />

**Diamond** (Randomized Character)
<img width="450" alt="image" src="https://github.com/user-attachments/assets/aa07c2e3-adf1-4bdd-94ec-e9ae2d5f676b" />

**Heart** (Randomized Number of Shapes)
<img width="450" alt="image" src="https://github.com/user-attachments/assets/d7b224c4-a8a3-4965-bd49-0ec26749d710" />

</details>

## Usage
### Running the Assembly Program
Assemble and link the `.asm` file using NASM and ld on a 32-bit Linux environment:
```bash
nasm -f elf32 shapes.asm -o shapes.o
ld -m elf_i386 shapes.o -o shapes
./shapes
```

### Running the Python Program
Execute the Python script directly via the terminal:
```bash
python3 Shapes.py
```

## Project Documentation
For a deep dive into the system architecture, branch prediction analysis, and an AI/ML enhancement proposal, please refer to the included `Group_37.pdf` research report.
