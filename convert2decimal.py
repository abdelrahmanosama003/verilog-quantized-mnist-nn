import re
import numpy as np

def parse_neuron_outputs(filename):
    neuron_outputs = {}

    with open(filename, 'r') as file:
        for line in file:
            match = re.match(r"# Neuron (\d+):\s+(-?\d+)", line)
            if match:
                neuron_index = int(match.group(1))
                output_value = int(match.group(2))
                neuron_outputs[neuron_index] = output_value

    return neuron_outputs

def softmax(logits, scale=256.0):
    logits = np.array([logits[i] for i in sorted(logits)], dtype=np.float32)
    logits /= scale  # convert from fixed-point
    logits -= np.max(logits)  # for numerical stability
    exp_logits = np.exp(logits)
    probs = exp_logits / np.sum(exp_logits)
    return probs

def predict_number(neuron_outputs):
    if not neuron_outputs:
        return None, None
    probs = softmax(neuron_outputs)
    predicted_neuron = int(np.argmax(probs))
    return predicted_neuron, probs

if __name__ == "__main__":
    filename = "transcript.log"
    outputs = parse_neuron_outputs(filename)
    prediction, probabilities = predict_number(outputs)
    print("\n" + "═" * 100 + "\n")
    if prediction is not None:
        for i, prob in enumerate(probabilities):
            print(f"Digit {i}: {prob.item() * 100:.2f}%")

        print("\n" + "═" * 50)
        print(f"✅ Predicted Digit by the SystemVerilog Model: {prediction}".center(50))
        print("═" * 50 + "\n")

    else:
        print("No neuron outputs found.")