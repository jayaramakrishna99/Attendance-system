import cv2
import numpy as np
import torch
import torchvision.transforms as transforms
from PIL import Image

# Load MiDaS Model from torch.hub
midas = torch.hub.load("intel-isl/MiDaS", "MiDaS_small")
midas.eval()

# Image transformation for MiDaS
transform = transforms.Compose([
    transforms.Resize((256, 256)),
    transforms.ToTensor(),
])

# Function to Estimate Depth
def estimate_depth(image):
    image = transform(image).unsqueeze(0)  # Add batch dimension
    with torch.no_grad():
        depth_map = midas(image)
    return depth_map.squeeze().numpy()

# Function to Check Liveness Using Depth Variance
def is_live_face(image_path):
    image = Image.open(image_path)
    depth_map = estimate_depth(image)
    depth_variance = np.var(depth_map)  # Calculate depth variance
    
    return depth_variance > 0.01  # Higher variance = real face
