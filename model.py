import sys
import os
import torch
import torch.nn.functional as F
import matplotlib.pyplot as plt
import numpy as np
from torchvision import datasets, transforms

# === CONFIG ===
SCALE = 256
data_mem_output_path = "SIM/data_in.mem"

# === Write input vector to data_in.mem ===
def write_input_mem(input_vector, path):
    os.makedirs(os.path.dirname(path), exist_ok=True)
    with open(path, "w") as f:
        for val in input_vector:
            f.write(f"{val & 0xFFFF:04X}\n")

# Load test dataset
transform = transforms.ToTensor()
test_dataset = datasets.MNIST(root='model', train=False, download=True, transform=transform)

# Parse index from command line
if len(sys.argv) != 2:
    print("Usage: python test_digit.py <image_index>")
    sys.exit(1)

try:
    index = int(sys.argv[1])
    if index < 0 or index >= len(test_dataset):
        raise ValueError
except ValueError:
    print("Please enter a valid index between 0 and", len(test_dataset) - 1)
    sys.exit(1)

# Load image and label
image, label = test_dataset[index]

# Show the image using matplotlib
plt.imshow(image.squeeze(), cmap='gray')
plt.title(f"True Label: {label}")
plt.axis('off')
plt.show()

# === Save to data_in.mem ===
image_np = image.view(-1).numpy()
x = np.clip(np.round(image_np * SCALE), 0, 255).astype(np.int16)
write_input_mem(x, data_mem_output_path)

# Define the model
class SmallMNISTNet(torch.nn.Module):
    def __init__(self):
        super(SmallMNISTNet, self).__init__()
        self.fc1 = torch.nn.Linear(784, 16)
        self.fc2 = torch.nn.Linear(16, 16)
        self.fc3 = torch.nn.Linear(16, 10)

    def forward(self, x):
        x = torch.flatten(x, 1)
        x = F.relu(self.fc1(x))
        x = F.relu(self.fc2(x))
        return self.fc3(x)

# Load the trained model
model = SmallMNISTNet()
model.load_state_dict(torch.load("model/mnist_model.pth"))
model.eval()

# Run inference
with torch.no_grad():
    image_input = image.view(1, -1)  # Shape: [1, 784]
    output = model(image_input)
    probabilities = F.softmax(output, dim=1)
    predicted = torch.argmax(probabilities, dim=1).item()

# Print probabilities
for i, prob in enumerate(probabilities.squeeze()):
    print(f"Digit {i}: {prob.item() * 100:.2f}%")

# Print predictions
print("\n" + "═" * 50)
print(f"✅ Predicted Digit by the PyTorch Model: {predicted}".center(50))
print("═" * 50 + "\n")

print("\n" + "═" * 100 + "\n")