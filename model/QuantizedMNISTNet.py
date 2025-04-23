import torch
import torch.nn as nn
import torch.nn.functional as F
from torchvision import datasets, transforms
from torch.utils.data import DataLoader
import numpy as np
import os

# === CONFIGURATION ===
SCALE_FACTOR = 256  # Match this with RTL implementation

# === QUANTIZATION HELPERS ===
def float_to_int16(val):
    return np.clip(np.round(val * SCALE_FACTOR), -32768, 32767).astype(np.int16)

def int16_to_float(val):
    return val.astype(np.float32) / SCALE_FACTOR

def quantize_tensor(tensor):
    return torch.clamp((tensor * SCALE_FACTOR).round(), -32768, 32767) / SCALE_FACTOR

# === ORIGINAL NETWORK (for training and exporting float weights) ===
class SmallMNISTNet(nn.Module):
    def __init__(self):
        super(SmallMNISTNet, self).__init__()
        self.fc1 = nn.Linear(784, 16)
        self.fc2 = nn.Linear(16, 16)
        self.fc3 = nn.Linear(16, 10)

    def forward(self, x):
        x = torch.flatten(x, 1)
        x = F.relu(self.fc1(x))
        x = F.relu(self.fc2(x))
        return self.fc3(x)

# === DATASET ===
transform = transforms.ToTensor()
train_dataset = datasets.MNIST(root='.', train=True, download=True, transform=transform)
train_loader = DataLoader(train_dataset, batch_size=64, shuffle=True)

# === TEST THE QUANTIZED MODEL ===
test_loader = DataLoader(
    datasets.MNIST(root='.', train=False, download=True, transform=transform),
    batch_size=1000, shuffle=False
)

# === TRAIN FLOAT MODEL ===
float_model = SmallMNISTNet()
optimizer = torch.optim.Adam(float_model.parameters(), lr=0.01)
criterion = nn.CrossEntropyLoss()

for epoch in range(25):
    for images, labels in train_loader:
        optimizer.zero_grad()
        output = float_model(images)
        loss = criterion(output, labels)
        loss.backward()
        optimizer.step()

# === EXPORT AND QUANTIZE WEIGHTS ===
def save_to_mem(name, arr, out_dir="../SIM", transpose=False):
    os.makedirs(out_dir, exist_ok=True)
    if transpose:
        arr = arr.T
    with open(os.path.join(out_dir, f"{name}.mem"), "w") as f:
        if arr.ndim == 2:
            for row in arr:
                for val in row:
                    f.write(f"{val & 0xFFFF:04x}\n")
        else:
            for val in arr:
                f.write(f"{val & 0xFFFF:04x}\n")

layers = {
    "fc1_weights": float_model.fc1.weight.detach().numpy(),
    "fc1_biases": float_model.fc1.bias.detach().numpy(),
    "fc2_weights": float_model.fc2.weight.detach().numpy(),
    "fc2_biases": float_model.fc2.bias.detach().numpy(),
    "fc3_weights": float_model.fc3.weight.detach().numpy(),
    "fc3_biases": float_model.fc3.bias.detach().numpy(),
}

quantized_layers = {name: float_to_int16(arr) for name, arr in layers.items()}

for name, array in quantized_layers.items():
    save_to_mem(name, array, transpose=False)

print("Saved quantized .mem files.")

# === PYTHON-SIDE RTL-SIMULATED MODEL ===
class FixedPointMNISTNet(nn.Module):
    def __init__(self, quant_weights):
        super(FixedPointMNISTNet, self).__init__()
        self.fc1_w = torch.tensor(int16_to_float(quant_weights['fc1_weights']), dtype=torch.float32)
        self.fc1_b = torch.tensor(int16_to_float(quant_weights['fc1_biases']), dtype=torch.float32)
        self.fc2_w = torch.tensor(int16_to_float(quant_weights['fc2_weights']), dtype=torch.float32)
        self.fc2_b = torch.tensor(int16_to_float(quant_weights['fc2_biases']), dtype=torch.float32)
        self.fc3_w = torch.tensor(int16_to_float(quant_weights['fc3_weights']), dtype=torch.float32)
        self.fc3_b = torch.tensor(int16_to_float(quant_weights['fc3_biases']), dtype=torch.float32)

    def forward(self, x):
        x = torch.flatten(x, 1)
        x = quantize_tensor(x)

        x = quantize_tensor(F.linear(x, self.fc1_w, self.fc1_b))
        x = quantize_tensor(F.relu(x))

        x = quantize_tensor(F.linear(x, self.fc2_w, self.fc2_b))
        x = quantize_tensor(F.relu(x))

        x = quantize_tensor(F.linear(x, self.fc3_w, self.fc3_b))
        return x


fixed_model = FixedPointMNISTNet(quantized_layers)
fixed_model.eval()

correct = 0
total = 0

with torch.no_grad():
    for images, labels in test_loader:
        outputs = fixed_model(images)
        _, predicted = torch.max(outputs, 1)
        total += labels.size(0)
        correct += (predicted == labels).sum().item()

accuracy = correct / total * 100
print(f"Quantized Model Accuracy (Python Sim): {accuracy:.2f}%")

torch.save(float_model.state_dict(), "mnist_model.pth")