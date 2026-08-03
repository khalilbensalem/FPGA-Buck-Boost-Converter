# ⚡ Real-Time FPGA Buck-Boost Converter

A real-time FPGA implementation of a **DC-DC Buck-Boost converter** developed using **MATLAB**, **Simulink**, **Simscape**, and **HDL Coder**, then deployed on a **Xilinx PYNQ-Z2 FPGA**.

This project demonstrates the complete workflow from converter modeling to automatic HDL generation, FPGA deployment, and real-time validation using the **NOA Toolbox**.

---

# 📖 Project Overview

This project focuses on the design and implementation of a real-time Buck-Boost DC-DC converter on FPGA.

The converter was first modeled using MATLAB/Simulink and Simscape before automatically generating synthesizable HDL code with HDL Coder. The generated hardware was then deployed onto a **Xilinx PYNQ-Z2 FPGA** using the **NOA Toolbox**, enabling real-time communication between MATLAB and the FPGA for rapid prototyping and experimentation.

Finally, the project evaluates the computational performance of FPGA-based execution compared to a conventional CPU implementation.

---

# 🚀 Features

- DC-DC Buck-Boost converter modeling
- MATLAB / Simulink implementation
- Simscape physical modeling
- Automatic HDL generation using HDL Coder
- 32-bit PWM generator
- PI controller implementation
- FPGA deployment on Xilinx PYNQ-Z2
- Real-time FPGA communication using the NOA Toolbox
- MATLAB and Jupyter Notebook visualization
- CPU vs FPGA performance comparison

---

# 🛠️ Technologies

- MATLAB
- Simulink
- Simscape
- HDL Coder
- Xilinx Vivado
- Xilinx PYNQ-Z2 FPGA
- NOA Toolbox
- Python
- Jupyter Notebook

---

# 🔧 NOA Toolbox

This project uses the **NOA Toolbox**, a Simulink-based development environment designed to simplify FPGA acceleration workflows. It enables engineers to deploy Simulink models onto PYNQ-enabled FPGA platforms while abstracting low-level hardware complexity and supporting hardware/software interaction.

The **NOA Toolbox** is developed by **Rexys Technologies** and provides an efficient framework for deploying, controlling, and validating FPGA-based applications directly from MATLAB/Simulink.

### More Information

- **[NOA Toolbox (MathWorks)](https://www.mathworks.com/products/connections/product_detail/noa-toolbox.html)**
- **[Rexys Technologies](https://rexys.io/fr/accueil/)**
  
---

# 👨‍💻 Author

**Khalil Ben Salem**

Electrical Engineering Student

Polytechnique Montréal
