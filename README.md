# verilog-quantized-mnist-nn
Quantized MNIST neural network trained in PyTorch and deployed on FPGA using SystemVerilog. Includes fixed-point conversion, RTL implementation, and simulation via QuestaSim. Compares PyTorch and hardware inference for digit classification.

# Quantized MNIST Neural Network - PyTorch & Verilog Simulation

This repository demonstrates a PyTorch-trained, quantized neural network for MNIST digit classification, with a Verilog RTL implementation for hardware simulation using QuestaSim.

## 🛠 Environment and Tools

Ensure you are using the following versions for compatibility:
- Python 3.8.0  
- PyTorch: `2.1.2`  
- TorchVision: `0.16.2`  
- Matplotlib: `3.7.5`  
- NumPy: `1.24.3`  
- Questa - Intel FPGA Starter Edition 2023.3 (Quartus Prime Pro 23.1std)

---

## 📦 Setup Instructions

1. **Clone the repository:**
   ```bash
   git clone https://github.com/yourusername/quantized-mnist-net.git
   cd quantized-mnist-net
   ```

2. **Install Python dependencies:**
   ```bash
   pip install -r requirements.txt
   ```

---

## 🚀 How to Run the Model

There are two ways to simulate the model:

### 🔧 Method 1: Using `sim.bat`

1. Open `sim.bat` and **edit line 15** to match your local QuestaSim installation path.
2. Run the batch file with an image index from 0 to 9999:
   ```bash
   .\sim.bat <image_index>
   ```

---

### 🧪 Method 2: Manual QuestaSim and Python Integration

1. Run the PyTorch inference script:
   ```bash
   python model.py %IMAGE_INDEX%
   ```

2. Open **QuestaSim**, and change the directory to the `SIM` folder inside this repo.

3. Run the simulation script:
   ```tcl
   do run.do
   ```

4. Parse the QuestaSim output using:
   ```bash
   python convert2decimal.py
   ```

---

## 📁 Project Structure

- `model/`  
  Contains:
  - MNIST dataset.
  - `mnist_model.pth`: Pre-trained model (95% accuracy).
  - `QuantizedMNISTNet.py`: Code to train and quantize the model.

- `RTL/`  
  Verilog RTL files implementing the neural network architecture.

- `SIM/`  
  Simulation folder containing:
  - `neural_network_tb.sv`: Testbench.
  - `run.do`: QuestaSim run script.
  - `*.mem`: Quantized weights, biases, and input image memory (`data_in.mem`).

- `model.py`  
  Runs inference on the PyTorch model and writes the processed image to the SIM folder.

- `convert2decimal.py`  
  Parses QuestaSim’s transcript to print digit probabilities after softmax.

---