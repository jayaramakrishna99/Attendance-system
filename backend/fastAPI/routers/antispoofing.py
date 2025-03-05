import cv2 # type: ignore
import torch # type: ignore
import torch.nn as nn # type: ignore
import torchvision.transforms as transforms # type: ignore
import torchvision.models as models # type: ignore

# 1. Load Anti-Spoofing Model

device = torch.device("cuda" if torch.cuda.is_available() else "cpu")

model = models.mobilenet_v2(pretrained=False)
model.classifier[1] = nn.Linear(model.last_channel, 2)
model.load_state_dict(torch.load("model/best_antispoof_model.pth", map_location=device))
model.to(device)
model.eval()

# 2. Define Image Transform for Anti-Spoofing

test_transform = transforms.Compose([
    transforms.ToPILImage(),
    transforms.Resize((224, 224)),
    transforms.ToTensor(),
    transforms.Normalize(mean=[0.485, 0.456, 0.406], std=[0.229, 0.224, 0.225])
])

# 3. Anti-Spoofing Check Function

def predict_spoof(image_path: str) -> bool:
    img = cv2.imread(image_path)
    if img is None:
        return False 

    img = cv2.cvtColor(img, cv2.COLOR_BGR2RGB)
    img_tensor = test_transform(img).unsqueeze(0).to(device)
    
    with torch.no_grad():
        outputs = model(img_tensor)
        _, predicted = torch.max(outputs, 1)

    return predicted.item() == 1  # 1 - Real, 0 - Spoofed