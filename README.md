1.	Created a new public GitHub repository to host the website's source code.
2.	Initialized the Git repository in the project directory.
git init
           Commit and push the code to the GitHub repository.
           git add .
           git commit -m "commit message"
           git remote add origin < github-repository-url>
           git push -u origin master
3.	Version Control with Git:
Committed changes regularly with descriptive messages.

4.	Using terraform, launched an Amazon EC2 instance with the Amazon Linux 2 AMI and configured the security group to allow inbound HTTP (port 80) and SSH (port 22) traffic.
5.	Install Necessary Software on EC2 Instance:
SSH into the EC2 instance and install required software, such as Apache web server and Git.
sudo yum update -y
sudo yum install httpd git -y

6.	Implement CI/CD with GitHub Actions:
Set up a GitHub Actions workflow (.github/workflows/main.yml) to trigger the CI/CD process.
Configured the workflow to run whenever changes are pushed to the main branch.
name: Deploy Code to Application Server

# Trigger deployment only on push to master branch
on:
  push:
    branches:
      - master

jobs:
  build:
    runs-on: ubuntu-latest

    steps:
      - name: Checkout repository
        uses: actions/checkout@v2

      - name: Set up Docker Buildx
        uses: docker/setup-buildx-action@master

      - name: Login to Docker Hub
        run: echo ${{ secrets.DOCKERHUB_TOKEN }} | docker login -u ${{ secrets.DOCKERHUB_USERNAME }} --password-stdin

      - name: Build and push Docker image
        run: |
          docker buildx create --use
          docker buildx inspect --bootstrap
          docker buildx build --load -t my-doc-app:latest .
          docker tag my-doc-app:latest ${{ secrets.DOCKERHUB_USERNAME }}/3504finalexam:latest
          echo $(docker images)
          docker push ${{ secrets.DOCKERHUB_USERNAME }}/3504finalexam:latest

      - name: Check Docker Image Build
        run: |
          if docker inspect my-doc-app:latest &> /dev/null; then
            echo "Docker image built successfully. Test passed!"
          else
            echo "Docker image not found. Test failed."
            exit 1
          fi

      - name: Check Docker Image Pushed
        run: |
          if docker manifest inspect ${{ secrets.DOCKERHUB_USERNAME }}/3504finalexam:latest &> /dev/null; then
            echo "Docker image pushed to Docker Hub successfully. Test passed!"
          else
            echo "Docker image not found on Docker Hub. Test failed."
            exit 1
          fi

      - name: Logout from Docker Hub
        run: docker logout

  deploy:
    needs: build
    runs-on: ubuntu-latest

    steps:
      - name: Executing remote ssh commands using ssh key
        uses: appleboy/ssh-action@master
        with:
          host: ${{ secrets.HOST_DNS }}
          username: ${{ secrets.USERNAME }}
          key: ${{ secrets.EC2_SSH_KEY }}
          script: |
            existing_container=$(docker ps -q -f name=my-doc-app)
            if [ ! -z "$existing_container" ]; then
                echo "Stopping and removing existing container..."
                docker stop $existing_container
                docker rm $existing_container
            fi
            docker login -u ${{ secrets.DOCKERHUB_USERNAME }} -p ${{ secrets.DOCKERHUB_TOKEN }}
            docker pull ${{ secrets.DOCKERHUB_USERNAME }}/3504finalexam:latest
            docker run -d -p 80:80 --name my-doc-app ${{ secrets.DOCKERHUB_USERNAME }}/3504finalexam:latest
            docker image prune -f
7.	Created a Dockerfile to containerize the website application.
Build a Docker image for your website.
FROM ubuntu:20.04
 
ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update -y && apt-get install -y apache2 php php-mysql
 
RUN rm -rf /var/www/html/index.html

COPY application-code/ /var/www/html/
 
EXPOSE 80
 
CMD ["apache2ctl", "-D","FOREGROUND"]
8.	Installed Docker on the EC2 instance.
      sudo apt-get update && \
sudo apt-get -y install ca-certificates curl gnupg && \
sudo install -m 0755 -d /etc/apt/keyrings && \
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg && \
sudo chmod a+r /etc/apt/keyrings/docker.gpg && \
echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null && \
sudo apt-get update && \
sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin && \
sudo chown $USER /var/run/docker.sock  && \
sudo newgrp docker && \
sudo usermod -a -G docker $USER && \
sudo systemctl enable docker.service && \
sudo systemctl enable containerd.service && \
sudo usermod -aG docker $USER

Transfer the Docker image from the local machine to the EC2 instance.
Run the Docker container to deploy the website.
docker run -d -p 80:80 image-name
9.	Opened the website using the public DNS of instance.
http://18.234.242.38/ 

GitHub Repository
https://github.com/arlingeo99/finalexam 
EC2
https://us-east-1.console.aws.amazon.com/ec2/home?region=us-east-1#InstanceDetails:instanceId=i-0b1bb9b90cac66d61 
RDS
https://us-east-1.console.aws.amazon.com/rds/home?region=us-east-1#database:id=main-db;is-cluster=false 
VPC
https://us-east-1.console.aws.amazon.com/vpcconsole/home?region=us-east-1#VpcDetails:VpcId=vpc-0dc2fdcaced0c0b58 


The CI/CD workflow is managed through GitHub Actions. Here's an overview:

Trigger: The workflow is triggered on each push to the main branch.
Steps:
Checkout Repository: The workflow checks out the latest code from the main branch.
Deploy to EC2: The workflow deploys the updated code to the EC2 instance.
Automatic Deployment: The workflow ensures automatic deployment by triggering on changes to the main branch. This allows for a seamless and continuous deployment process.
10.	Testing:
I have tested the website manually by going through all major functionalities/features of website. Checked if all the pages, images, buttons, form etc are working as expected.
To test the website functionality within the docker container, I have updated the CI/CD workflow with a test case in it.
    name: Deploy Code to Application Server

# Trigger deployment only on push to master branch
on:
  push:
    branches:
      - master

jobs:
  build:
    runs-on: ubuntu-latest

    steps:
      - name: Checkout repository
        uses: actions/checkout@v2

      - name: Set up Docker Buildx
        uses: docker/setup-buildx-action@master

      - name: Login to Docker Hub
        run: echo ${{ secrets.DOCKERHUB_TOKEN }} | docker login -u ${{ secrets.DOCKERHUB_USERNAME }} --password-stdin

      - name: Build and push Docker image
        run: |
          docker buildx create --use
          docker buildx inspect --bootstrap
          docker buildx build --load -t my-doc-app:latest .
          docker tag my-doc-app:latest ${{ secrets.DOCKERHUB_USERNAME }}/3504finalexam:latest
          docker push ${{ secrets.DOCKERHUB_USERNAME }}/3504finalexam:latest

      - name: Check Docker Image Build
        run: |
          if docker inspect my-doc-app:latest &> /dev/null; then
            echo "Docker image built successfully. Test passed!"
          else
            echo "Docker image not found. Test failed."
            exit 1
          fi

      - name: Check Docker Image Pushed
        run: |
          if docker manifest inspect ${{ secrets.DOCKERHUB_USERNAME }}/3504finalexam:latest &> /dev/null; then
            echo "Docker image pushed to Docker Hub successfully. Test passed!"
          else
            echo "Docker image not found on Docker Hub. Test failed."
            exit 1
          fi

      - name: Logout from Docker Hub
        run: docker logout

  deploy:
    needs: build
    runs-on: ubuntu-latest

    steps:
      - name: Executing remote ssh commands using ssh key
        uses: appleboy/ssh-action@master
        with:
          host: ${{ secrets.HOST_DNS }}
          username: ${{ secrets.USERNAME }}
          key: ${{ secrets.EC2_SSH_KEY }}
          script: |
            existing_container=$(docker ps -q -f name=my-doc-app)
            if [ ! -z "$existing_container" ]; then
                echo "Stopping and removing existing container..."
                docker stop $existing_container
                docker rm $existing_container
            fi
            docker login -u ${{ secrets.DOCKERHUB_USERNAME }} -p ${{ secrets.DOCKERHUB_TOKEN }}
            docker pull ${{ secrets.DOCKERHUB_USERNAME }}/3504finalexam:latest
            docker run -d -p 80:80 --name my-doc-app ${{ secrets.DOCKERHUB_USERNAME }}/3504finalexam:latest
            docker image prune -f

      - name: Test Website Functionality
        run: |
          response_code=$(curl -s -o /dev/null -w "%{http_code}" http://${{ secrets.HOST_DNS }}/)
          if [ "$response_code" -eq "200" ]; then
            echo "Site is accessible. Test passed!"
          else
            echo "Site is not accessible. Test failed."
            exit 1
          fi

Challenges:
As a student undertaking this project, I encountered challenges in Terraform configuration errors and AWS resource dependencies.
Dockerization presented hurdles in optimizing the Dockerfile for the website and debugging container issues. These challenges, though initially daunting, served as valuable learning experiences. 
Through careful debugging, exploration, and active learning, I not only overcame these obstacles but also deepened my understanding of Terraform and Docker. The process emphasized the significance of perseverance and a growth mindset in navigating complexities and mastering new technologies.




