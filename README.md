# terraform-aws-iac-learning

## Overview
This project aims to build a comprehensive learning platform for Infrastructure as Code (IaC) using Terraform on AWS. It encompasses various modules for networking, compute, and storage, along with a Docker deployment strategy. The goal is to create a robust and scalable infrastructure while documenting the learning journey.

## Project Structure
- **docs/**: Contains notes and documentation on AWS basics, Terraform fundamentals, Docker deployment, and integration strategies.
- **terraform/**: Houses the Terraform configuration files, including modules for networking, compute, and storage, as well as environment-specific configurations.
- **docker/**: Contains the Dockerfile for building the application image.
- **.gitignore**: Specifies files and directories to be ignored by Git.
- **README.md**: This file, providing an overview and instructions for the project.
- **COPILOT_INSTRUCTIONS.md**: A guide outlining the learning and execution plans for the project.

## Setup Instructions
1. **Clone the Repository**: 
   ```bash
   git clone <repository-url>
   cd terraform-aws-iac-learning
   ```

2. **Install Prerequisites**:
   - Ensure you have [Terraform](https://www.terraform.io/downloads.html) installed.
   - Install [Docker](https://docs.docker.com/get-docker/).
   - Set up an AWS account and configure your AWS CLI.

3. **Initialize Terraform**:
   Navigate to the `terraform` directory and run:
   ```bash
   terraform init
   ```

4. **Configure Environment Variables**:
   Update the `terraform/environments/dev/terraform.tfvars.example` file with your specific variable values.

5. **Deploy Infrastructure**:
   Run the following commands in the `terraform/environments/dev` directory:
   ```bash
   terraform plan
   terraform apply
   ```

6. **Build Docker Image**:
   Navigate to the `docker` directory and run:
   ```bash
   docker build -t <image-name> .
   ```

## Usage Guidelines
- Refer to the `docs/` directory for detailed notes and learning materials.
- Use the Terraform modules to customize and extend your infrastructure as needed.
- Document any challenges and solutions in the `docs/04-integration-journey.md` file.

## Contribution
Feel free to contribute by adding more modules, improving documentation, or sharing your learning experiences. 

## License
This project is licensed under the MIT License - see the LICENSE file for details.