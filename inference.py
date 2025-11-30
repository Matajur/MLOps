"""Module for predicting the 3 most likely classes based on an image"""

import sys
import torch
from torchvision import transforms
from PIL import Image

# Loading the traced model
model = torch.jit.load("model.pt")
model.eval()

preprocess = transforms.Compose(
    [transforms.Resize(256), transforms.CenterCrop(224), transforms.ToTensor()]
)


def predict(image_path: str) -> None:
    """Predict the 3 most likely classes for a given image."""
    image = Image.open(image_path).convert("RGB")
    input_tensor = preprocess(image).unsqueeze(0)

    with torch.no_grad():
        output = model(input_tensor)
        probabilities = torch.softmax(output, dim=1)
        top3_probs, top3_ids = torch.topk(probabilities, 3, dim=1)

        print("🧠 Tot 3 classes ID:")
        for i in range(3):
            print(
                f"{i+1}. ID: {top3_ids[0][i].item()} | Probability: {top3_probs[0][i].item():.4f}"
            )


if __name__ == "__main__":
    predict(sys.argv[1])
