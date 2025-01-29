
# **VFSTR Attendance System** 📷✅  

## **Overview**  
The **VFSTR Attendance System** is a mobile application built using **Flutter**, **FastAPI**, and **MySQL** to automate faculty attendance tracking using facial recognition. Faculty members can register, log in, and mark their attendance using a captured image, which is verified using a deep learning face recognition model.

---

## **Features** 🚀  
✔ **Faculty Registration** – Faculty members can register by providing their **ID, Name, and Image**.  
✔ **Face Recognition-Based Login** – Faculty can log in by capturing an image, which is verified with stored records.  
✔ **Attendance Marking** – If the captured image matches the stored faculty image, attendance is marked automatically.  
✔ **Secure Data Storage** – Faculty details and attendance records are stored securely in **MySQL**.  
✔ **FastAPI Backend** – A backend built using **FastAPI** handles authentication and image verification.  
✔ **User-Friendly UI** – Simple and modern UI with a **dark green and cream** color theme (`rgb(81,97,91)` and `rgb(245,241,230)`).  
✔ **Navigation Bar** – Provides quick access to **Welcome, Login, and Register screens**.  

---

## **Tech Stack** 🛠  
### **Frontend** (Mobile App)  
- **Flutter** (Dart)  
- **Material UI**  
- **Flutter Camera Plugin**  

### **Backend**  
- **FastAPI** (Python)  
- **DeepFace** for face recognition  
- **MySQL** for database storage  
- **HTTP Requests (REST API)** for communication  

---

## **Screenshots** 📸  
(Add relevant images here, e.g., UI screenshots of Login, Register, and Home screens.)  

---

## **Installation Guide** ⚙  

### **1. Clone the Repository**  
```bash
git clone https://github.com/your-username/VFSTR-Attendance-System.git
cd VFSTR-Attendance-System
```
### **2. Set Up the Flutter App**
Install Flutter SDK from the official website: https://flutter.dev/docs/get-started/install
Run the following command to install dependencies:
```bash
flutter pub get
```
To run the app on an emulator or device:
```bash
flutter run
```
### **3. Set Up the Backend(FastAPI)**
Navigate to the backend folder:
```bash
cd backend
```
Install Python dependencies:
```bash
pip install -r requirements.txt
```
Start the FastAPI server:
```bash
uvicorn main:app --host 0.0.0.0 --port 8000
```
### **4. Set Up MySQL Database**
Install MySQL Server and create a new database.
Update the database credentials in the backend/main.py file.

---
### **Usage 📱**
1. Register: Facult members sign up with their ID, Name, and Image.
2. Login: Faculty log in by capturing their image, which is matched with stored records.
3. Mark Attendance: Upon successful verification, attendance is recorded in the database.
---
### **Contributing 🤝**
We welcome contributions! Please follow these steps:
1. Fork the repository
2. Create a new branch (feature-branch)
3. Commit your changes (git commit -m "Added new feature")
4. Push to your fork (git push origin feature-branch)
5. Submit a Pull Request 🎉

---

### **License 📜**

This project is licensed under the MIT License. Feel free to modify and use it for your needs.

---

### **Contact 📧**

For any inquiries or feedback, please contact:

👨‍💻 **Developer**: [Jayarama Krishna](https://github.com/jayaramakrishna99)  
📧 **Email**: [jayaramakrishnachallagundla@gmail.com](mailto:jayaramakrishnachallagundla@gmail.com)  
🔗 **GitHub**: [github.com/jayaramakrishna99](https://github.com/jayaramakrishna99)



