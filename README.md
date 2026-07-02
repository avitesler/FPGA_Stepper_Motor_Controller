# FPGA Stepper Motor Controller

A fully digital, FSM-based Stepper Motor Controller implemented in SystemVerilog for FPGA applications.

## 🎥 Hardware Demonstration

<img width="604" height="341" alt="FPGA 4" src="https://github.com/user-attachments/assets/fc2b7a94-eb9b-4ac2-a3e0-0a39922548ad" />

*Above: The stepper motor being driven by the FPGA, demonstrating accurate speed control and direction switching.*

▶️ **Watch the Full Hardware Demo:**
Due to file size limits, the full video demonstrating the motor's real-time speed control and directional switching running on the FPGA is hosted in the documentation folder under the name 'Stepper Motor on FPGA.mp4'.

[Click here to watch the FPGA Hardware Demonstration Video](./docs)

**Hardware Setup & Connections:**

The FPGA's GPIO pins interface with an L298 Dual H-Bridge Motor Driver to accurately control the coil sequences of a bipolar stepper motor.

<img width="601" height="332" alt="Full System" src="https://github.com/user-attachments/assets/ceb7e24d-b613-4ca8-ba11-9b1268fcedda" />

---

## 📌 Project Overview
This project implements a digital controller for a stepper motor. Designed using SystemVerilog and synthesized via Intel Quartus Prime, the system provides real-time control over motor speed, rotational direction, and step resolution (full-step / half-step). 

### Key Features:
* **Dual Operation Modes:**
  * *Continuous Run:* The motor spins continuously while the `on` signal is active.
  * *Quarter-Turn Mode:* A dedicated counter limits the motor to exactly 100 steps (a precise 90-degree turn) before automatically halting.
* **FSM-Based Speed Control:** A 6-state Moore Finite State Machine manages smooth acceleration and deceleration, preventing sudden mechanical jerks.
* **Hardware Debouncing:** Edge-detector logic filters long button presses, ensuring reliable single-state transitions.
* **Visual Feedback:** 7-Segment displays indicate the current speed state (S1 to S6) in real-time.

---

## 🏗️ System Architecture

The architecture separates the control path from the data path, ensuring modularity and reliable timing constraints across a 50MHz clock domain.

<img width="1520" height="760" alt="block diagram" src="https://github.com/user-attachments/assets/43735c26-263d-4883-9b1a-ff177b1b777e" />

### Module Descriptions:
* `step_motor_top`: The top-level entity routing all internal signals, linking the controllers, frequency dividers, and 7-segment displays.
* `speed_control_fsm`: An Up/Down State Machine navigating between 6 discrete speed levels. It outputs target threshold values for the frequency divider.
* `counter`: A parameterized generic counter used flexibly across the design—both as a highly configurable frequency divider for speed timing, and as a fixed step-tracker for the quarter-turn logic.
* `seg_7`: A combinational decoder driving the physical 7-segment displays to provide immediate visual feedback of the current speed state.
* `mode_controller`: Orchestrates the priority logic between continuous rotation and the 100-step quarter-turn limitation.
* `driver_control`: Translates the system's directional and step-size parameters into the exact 4-bit sequence required to activate the motor coils.

### Speed Control FSM
The core speed regulation is managed by a 6-state Moore machine (S1 through S6). It ensures sequential acceleration and deceleration to prevent mechanical stress on the motor, and implements a boundary "ping-pong" logic to automatically reverse the state progression when reaching maximum or minimum speeds.

<img width="721" height="251" alt="speed_control_fsm" src="https://github.com/user-attachments/assets/5f58afae-f193-4933-bc82-0fa3e29451ab" />

### Coil Activation FSM (Driver Logic)
The internal motor driver relies on an 8-state FSM to dictate coil behavior based on step size (half/full).

<img width="561" height="491" alt="driver_control_fsm" src="https://github.com/user-attachments/assets/b941b8e6-10a4-4d13-a27e-f78597459d5e" />

---

## 🧪 Verification & Simulation

The design was verified using ModelSim. The verification environment utilizes modular, **self-checking testbenches** designed to automatically compare outputs against expected theoretical values, logging errors directly in the simulation console.

Instead of manual wave inspection, the testbenches cover asynchronous reset recoveries, edge-detector validation, state boundary ping-pong logic, and operation mode collisions.

📁 **Simulation Waveforms:**
All detailed waveform captures and module-specific simulation close-ups can be found in the dedicated simulations folder: 
[Click here to view the simulation screenshots](./docs/simulations)

📝 **Full Verification Plan:**
The complete verification methodology and test plan document is available here:
[Click here to view the Test Plan](./docs/Verification_Test_Plan.pdf)

---

## 📬 Contact

- **Author:** [Avi Tesler]
- **Email:** [tesleravi1@gmail.com]
 
- **LinkedIn:** [www.linkedin.com/in/avi-tesler-0016ab377]
 
- **GitHub:** [https://github.com/avitesler]

---

## 📄 License

This project is released under the [MIT License](LICENSE).
