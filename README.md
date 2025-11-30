# Tier 3. Module 3 - MLOps CI/CD

## Homework for Topic 3 - Containerization of ML models

### Technical task

This task will help you to consolidate the fundamental skills of MLOps and practice scripting, automation, containerization, and runtime optimization for ML services.

#### Task description

Your goal:

- Create a script to install Docker, Docker Compose, Python, and ML dependencies.
- Build 2 Docker images for the PyTorch model: “heavy” and optimized (slim).
- Create a simple inference service in Python with a TorchScript model.
- Write a short report in Markdown with comparison and analysis.

#### Task steps

1. Bash script to prepare the environment

Create a Bash script `install_dev_tools.sh` that automates the environment setup for DevOps and ML development:

- Checks if Docker, Docker Compose, Python ≥ 3.9, pip, Django, torch, torchvision, pillow are installed
- If not, installs:
- Docker and Docker Compose
- Python (via apt or pyenv if the system is older)
- pip
- libraries: `torch`, `torchvision`, `pillow`

The script should be idempotent - re-execution should not result in errors or reinstallation.

Add a tool version check after installation and logging in the install.log file.

2. Containerize the ML service

- Load one of the `torchvision.models` models (for example, `mobilenet_v2`) and save it in `.pt` (TorchScript) format.
- Write `inference.py` that takes an image as input and outputs the top 3 classes.
- Create 2 Dockerfiles:

__Fat image__

- Based on `ubuntu` or `python:3.9`
- Installs all system dependencies and Python libraries
- Copies the `.pt` model and the `inference.py` script
- Has a large size (>1GB)

__Slim image__

- Multi-stage approach:
- First stage: install dependencies
- Second stage: only `inference.py`, `.pt` model, runtime without `apt`
- The goal is to reduce the image size to a minimum

After building:

- Run both images with any example image
- In `report.md` or `comparison.txt`, compare and note:
- Image size
- Number of layers
- Presence of unnecessary tools
- Suggestions for further optimization

#### Preparing and uploading the homework

To make the homework correctly formatted and convenient for checking, follow the instructions below.

1. Create a separate branch `lesson-3` in your GitLab repository

In the terminal, go to the folder with your GitLab repository and run:

```bash
git checkout -b lesson-3
```

Add the changes to the commit:

```bash
git add .
git commit -m "Add lesson-3: TorchScript model, Dockerfiles, report"
git push --set-upstream origin lesson-3
```

2. Add all the necessary files to the project

The `lesson-3` branch must contain the following files:

```
lesson-3/
├── inference.py
├── export_model.py
├── model.pt
├── Dockerfile.fat
├── Dockerfile.slim
├── install_dev_tools.sh
├── comparison.txt (or report.md)
└── README.md (with short instructions for launching)
```

3. Create a `.zip` archive

Make sure you are in the folder with all the necessary files and run:

```bash
zip -r DZ3_LastName_FirstName.zip .
```

Or, if you are in the root of the repository and your files are in the folder `lesson-3`:

```bash
zip -r DZ3_LastName_Andrey.zip lesson-3/
```

Check the contents of the archive before uploading:

```bash
unzip -l DZ3_LastName_Andrey.zip
```

4. Upload the archive to LMS and attach a link to the GitHub branch (`lesson-3`).

Finally, check:

- Can you build both images (`docker build -f Dockerfile.fat/slim .`)
- Does `inference.py` run inside the container
- Whether the README contains a short instruction on building and running
