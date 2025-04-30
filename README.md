# Five-Cycle Non-Pipelined RISC Processor (25-bit) – Verilog HDL

### 📘 Course: CSE302 – Computer Organization and Architecture  
### 👨‍🏫 Instructor: Prof. Mazad Zaveri  
### 👥 Group Members:
- Nirmam Parikh (AU2340253)  
- Parin Patel (AU2340243)  
- Dev Kansara (AU2340222)  
- Utsav Panchal (AU2340122)

---

## 📌 Project Overview

This project implements a **25-bit RISC (Reduced Instruction Set Computer) processor** using **Verilog HDL** based on a **five-stage non-pipelined architecture**. It follows the RISC design philosophy of simplified instruction sets for faster execution and greater hardware efficiency.

### 🧠 Processor Stages:
1. **Instruction Fetch (IF)**  
2. **Instruction Decode (ID)**  
3. **Execute (EX)**  
4. **Memory Access (MEM)**  
5. **Write Back (WB)**

---

## 🔧 Processor Modules and Coding Styles

| Module              | Coding Style          |
|---------------------|-----------------------|
| `RISCprocessor`     | Structural            |
| `eightbitRegwithLoad` | Behavioral         |
| `RegisterFile`      | Structural            |
| `InstMEM`           | Behavioral            |
| `SRAM`              | Behavioral            |
| `Stack`             | Behavioral            |
| `ALU`               | Structural + Dataflow |
| `TimingGen`         | Behavioral            |
| `ProgCounter`       | Behavioral            |
| `INport`            | Structural            |
| `OUTport`           | Structural            |
| `ControlLogic`      | Structural            |

---

## 🧾 Instruction Format

**Example Instruction:** `MOVI R2 ← 0x41`  
**Binary Representation:**

01010 0010 0000 0000 01000001 
                    |────────|──── Immediate Data (8 bits)
               |────|───────────── Source Register 2 (5 bits)
          |────|────────────────── Source Register 1 (5 bits)
     |────|─────────────────────── Destination Register (5 bits)
|────|──────────────────────────── Opcode (5 bits)




