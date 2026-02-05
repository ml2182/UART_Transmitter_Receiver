# UART RX TX
## Overview
This project implements an Universal Asynchronous Receiver and Transmitter (UART) in SystemVerilog. This module is designed to support duplex serial data communication. 
- The TX is a parallel-to-serial converter, containing the start, data, and stop bits.
- The RX is a serial-to-parallel converter, which reconstructs the serial data. To reconstruct the data accurately, the module uses oversampling. Oversampling is where, instead of sampling each bit at a single point, it samples at multiple points per bit. This allowed the RX module to use majority voting to determine the correct value of each bit, improving accuracy.

In addition, I implemented FIFO input and output buffers. This allows the TX to accept data at the frequency of the clock, rather than waiting until the serial communication line is IDLE. The benefits of the buffers are that it simplifies control logic, handles the speeds mismatches between communication and clock and decouples transmitter and receiver. 

The TX, RX and FIFO are all parameterised. Therefore, this allows for the clock frequency, baud rate and data width etc. to be adapted for different hardware and communication protocols. 

I verified this project using modular SystemVerilog testbenches which enable both the receiver and transmitter to be tested independently. In the testbenches, I used various techniques to ensure successful transmission and reception, from using large number of random input bits to a loopback test. Through this and analysis of the simulated waveform, I was able to build the UART.
## Testbench Verification
Below is the simulated waveform of the loop back test:
<img width="1883" height="648" alt="image" src="https://github.com/user-attachments/assets/57141eea-ad6e-42bd-8269-9919fab95c51" />
I carried out the loop back test for 100 randomly generated inputs, and all the tests passed successfully.

## What I Learnt
I gained experience in:
- Designing an asynchronous serial communication interface from the ground up.
- Implementing FIFO buffers to manage data flow.
- Developing FSMs and shift registers.
- Building modular testbenches and using waveform analysis to verify HDL designs .

## Further Improvements
Implementing error detection (Parity Bit). I would have to add another state at TX which transmits a odd/even parity bit, depending on the data transmitted. The RX would calculate the number of 1s received in the byte of data. If it follows the protocol agreed upon, it would accept/reject the byte of data. Also, I can further implement framing error detection and advance flow control for higher reliability. These features are not yet implemented due to time constraints.

## Folder Structure
- `src/` — HDL source files
- `scripts/` — TCL automation scripts
