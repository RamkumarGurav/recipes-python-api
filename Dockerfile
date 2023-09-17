# Use the Python 3.9 Alpine base image from Docker Hub
#This Dockerfile is used to build a Docker image for a Python 3.9-based Django application using Alpine Linux as the base image
FROM python:3.9-alpine3.13

# Set the maintainer label to identify the image maintainer
LABEL maintainer="ramkumarsgurav@gmail.com"

# Set an environment variable to ensure Python doesn't buffer its output
ENV PYTHONUNBUFFERED 1

# Copy the requirements.txt file from the local machine to /temp/requirements.txt in the image
COPY ./requirements.txt /temp/requirements.txt

# Copy the requirements.txt file from the local machine to /temp/requirements.txt in the image
COPY ./requirements.dev.txt /temp/requirements.dev.txt
# Copy the entire Django application directory from the local machine to /app in the image
COPY ./app /app

# Set the working directory within the container to /app
WORKDIR /app

# Expose port 8000 within the container to allow external access
EXPOSE 8000

# addin DEV environment variable with default value of false
ARG DEV=false
# Create a virtual environment and install dependencies #below code executes in shell so it's shell's script
RUN python -m venv /py && \
    /py/bin/pip install --upgrade pip && \
    /py/bin/pip install -r /temp/requirements.txt && \
    apk add --update --no-cache postgresql-client && \
    apk add --update --no-cache --virtual .temp-build-deps \
    build-base postgresql-dev musl-dev && \
    if [ "$DEV" = "true" ]; then /py/bin/pip install -r /temp/requirements.dev.txt; fi && \
    rm -rf /tmp && \
    apk del .temp-build-deps
#RUN python -m venv /py && \
# This line creates a Python virtual environment named /py within the Docker container. A virtual environment is a self-contained Python environment that allows you to manage dependencies separately for your project.
# python -m venv /py uses the venv module to create the virtual environment at the /py directory.
# The && \ at the end of the line is used to concatenate multiple commands into a single RUN instruction.
# /py/bin/pip install --upgrade pip && \

# After creating the virtual environment, this line upgrades the pip package manager inside the virtual environment to the latest version.
# /py/bin/pip specifies the path to the pip executable within the virtual environment.
# --upgrade pip ensures that pip itself is upgraded to the newest version.
# /py/bin/pip install -r /temp/requirements.txt && \

# This line installs Python dependencies listed in the /temp/requirements.txt file into the virtual environment.
# /py/bin/pip specifies the path to the pip executable within the virtual environment.
# -r /temp/requirements.txt instructs pip to read the dependencies from the requirements.txt file and install them.
# && \ is used again to concatenate multiple commands into a single RUN instruction.

# if [ "$DEV" = "true" ]; then: This line begins a conditional statement. It checks if the value of the DEV variable is equal to "true."

# /py/bin/pip install -r /temp/requirements.dev.txt;: If the DEV variable is equal to "true," this command installs development dependencies listed in requirements.dev.txt into the virtual environment. The semicolon (;) is used to separate commands within the same line.

# fi: This marks the end of the conditional statement. If DEV is not equal to "true," the installation of development dependencies is skipped.

# rm -rf /tmp
# This command removes the /tmp directory and its contents within the Docker container.
# /tmp typically contains temporary files, and it's good practice to clean up such files to reduce the size of the Docker image.
# Overall, these lines of code create a virtual environment, upgrade pip, install project-specific dependencies from requirements.txt, and then clean up any temporary files, ensuring that your Python application runs with the correct dependencies within the Docker container.    

#Creates a non-root user named 'django-user' without a password and home directory.
RUN adduser \
    --disabled-password \
    --no-create-home \
    django-user



# Adds the virtual environment's bin directory to the PATH to ensure the correct Python interpreter and pip are used.
ENV PATH="/py/bin:$PATH"

# Set the user to 'django-user' for improved security
USER django-user
# The "adduser" block in this Dockerfile serves the purpose of creating a new user within the Docker image. This practice aligns with security best practices, as it is recommended not to run applications with the root user inside a container. The root user has unrestricted access and privileges, which can pose security risks if the application becomes compromised. By creating a separate user, in this case named "django-user," with limited permissions, you enhance the security of your container.

# The specific configuration in the "adduser" block includes:

# --disabled-password: This flag indicates that the user will not have a password set for authentication.

# --no-create-home: It prevents the creation of a home directory for the user, as it's not necessary for this context.

# django-user: Specifies the name of the user being created.

# After creating the user, the Dockerfile updates the PATH environment variable to include the binary directory of the virtual environment created earlier. This addition ensures that when you run commands within the container, they will use the virtual environment without needing to specify the full path.

# Lastly, the Dockerfile concludes with the "USER" line, which designates the user that the container will use when executing commands. In this case, it sets the user to "django-user," ensuring that any commands run within the container will have the limited permissions associated with this user, contributing to enhanced container security.





# This Dockerfile is used to build a Docker image for a Python 3.9-based Django application using Alpine Linux as the base image. It starts by specifying the base image, setting a maintainer label for identification, and configuring an environment variable to ensure Python doesn't buffer its output. Next, it copies the project's requirements.txt file and the entire Django application directory into the image. The working directory is set to the /app directory, and port 8000 is exposed to allow external access. The Dockerfile then proceeds to create a virtual environment within the container, upgrades pip, installs project dependencies from requirements.txt, and cleans up temporary files. A non-root user named 'django-user' is created for security reasons. Finally, it adds the virtual environment's binary directory to the PATH and sets the user to 'django-user.' This Dockerfile ensures a clean and efficient environment for running the Django application within a Docker container while following best practices for security and container size optimization