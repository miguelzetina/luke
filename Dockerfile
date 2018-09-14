FROM python:3.4
ENV PYTHONUNBUFFERED 1

# Install packages
RUN apt-get update
RUN apt-get install apt-transport-https sudo -y

# Create User docker
RUN useradd -ms /bin/bash docker
RUN echo "docker ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

# create env valies
ENV PROJECT_DIR /home/docker/public
ENV MEDIA_DIR /home/docker/media
ENV REQUIREMENTS_DIR /home/docker/public/requirements
ENV OHMYZSH_DIR /home/docker/.oh-my-zsh


# Create Folders
RUN mkdir $PROJECT_DIR
RUN mkdir $MEDIA_DIR
RUN mkdir $REQUIREMENTS_DIR
RUN mkdir $OHMYZSH_DIR

# Change owner and group
RUN chown -R docker:docker $PROJECT_DIR
RUN chown -R docker:docker $MEDIA_DIR

# Install Oh My Zsh
CMD ["zsh"]
RUN if [ ! -d $OHMYZSH_DIR ]; then sudo -Hu docker bash -c "git clone https://github.com/robbyrussell/oh-my-zsh.git $OHMYZSH_DIR"; fi

# Copy requirements files
COPY src/requirements/base.txt /home/docker/public/requirements
COPY src/requirements/local.txt /home/docker/public/requirements
COPY src/tox.ini /home/docker/public

# Install oh my zsh
COPY docker-templates/.bashrc /home/docker
COPY docker-templates/.profile /home/docker
COPY docker-templates/zsh/zprofile /home/docker
COPY docker-templates/zsh/zshrc /home/docker/.zshrc

# Install pip requiremntes
RUN pip3 install -r $REQUIREMENTS_DIR/local.txt

# Install Django Project
CMD if [ ! -d  "$PROJECT_DIR" ]; then sudo -Hu docker bash -c "django-admin.py startproject $PROJECT_NAME $PROJECT_DIR/.."; fi
CMD mkdir $PROJECT_DIR/settings
ADD docker-templates/django/utils $PROJECT_DIR/utils
RUN chown -R docker:docker $PROJECT_DIR/..

CMD docker-templates/django/settings_base.py $PROJECT_DIR/settings/__init__.py
CMD docker-templates/django/settings_local.py $PROJECT_DIR/settings/local.py
CMD docker-templates/django/settings_staging.py $PROJECT_DIR/settings/staging.py
CMD docker-templates/django/settings_testing.py $PROJECT_DIR/settings/testing.py


# Init Project
WORKDIR /home/docker/public
USER docker
