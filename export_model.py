"""Module for exporting MobileNet V2 model"""

import torch
from torchvision import models

# Loading the pre-trained MobileNet V2 model
model = models.mobilenet_v2(weights=models.MobileNet_V2_Weights.DEFAULT)
model.eval()  # Switching to inference mode

# Creating a "sample input" needed for model tracing
dummy_input = torch.rand(1, 3, 224, 224)

# Model tracing in TorchScript (make PyTorch model portable)
traced_model = torch.jit.trace(model, dummy_input)

# Saving the model
traced_model.save("model.pt")
print("✅ Model saved to model.pt")
