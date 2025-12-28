# UART RX TX
## Overview
In this project, I set out the goal to build a Universal Asynchronous Receiver and Transmitter (UART) in SystemVerilog. This module is designed to support duplex serial data communication. The TX module serialises the parallel data, with the correct start, data, and stop bits. The RX receives the serial data, uses oversampling to ensure the correct detection each transmitted bit, reconstructs the serial data back into parallel data and outputs it. 

In addition, I implemented a FIFO input and output buffer. This allows for data at the TX to be added at the frequency of the clock, rather than having to input the data when the serial communication is IDLE. The benefits of the buffer are that it simplifies control logic, manages the speeds mismatches between communicaion and clock and decouples transmitter and receiver. 

I wanted this project to be adaptable for a range of different purposes, so I parameterised the clock frequency, baud rate and data width. This allows the HDL to be used on different hardware and communication protocols. 

I verified this project using modular SystemVerilog testbenches which enable both the receiver and transmitter to be tested independently. In the testbenches, I used various techniques to ensure successful transmission and reception, from using large number of random input bits to a loopback test. Through this and analysis of the simulated waveform, I was able to build the UART.
## Testbench Verification
Below is the simulated waveform of the loop back test:
<img width="1883" height="648" alt="image" src="https://github.com/user-attachments/assets/57141eea-ad6e-42bd-8269-9919fab95c51" />

After the completion of the data tramission, the received data outputs the corresponding input data.

## What I learnt
I learnt how to build a asynchronous serial communication interface from scratch, implement a FIFO buffer, further developed my knowledge of FSMs, shift registers and testbench verifications. 

## Further Improvements
Implementing error detection

## Folder structure
- `src/` — HDL source files
- `scripts/` — TCL automation scripts
