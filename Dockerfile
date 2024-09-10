
FROM ubuntu:20.04

ARG DEBIAN_FRONTEND=noninteractive

# Install essential packages and setup 
RUN apt update && apt install -y curl gnupg2 lsb-release \
    && curl -sSL https://raw.githubusercontent.com/ros/rosdistro/master/ros.asc | apt-key add - \
    && sh -c 'echo "deb http://packages.ros.org/ros2/ubuntu $(lsb_release -cs) main" > /etc/apt/sources.list.d/ros2-latest.list'

RUN apt update && apt install -y \
    wget 
    lsb-release \
    software-properties-common && \
    apt clean && \
    wget https://apt.kitware.com/kitware-archive.sh && \
    bash kitware-archive.sh && \
    apt update && apt install -y cmake

#dependencies
RUN apt update && apt install -y \
    git\
    python3-pip \
    python3-colcon-common-extensions \
    python3-rosdep \
    build-essential \
    ros-foxy-joy \
    ros-foxy-rviz2 \
    ros-foxy-teleop-twist-joy \
    ros-foxy-teleop-twist-keyboard \
    ros-foxy-laser-proc \
    ros-foxy-depthimage-to-laserscan \
    ros-foxy-navigation2 \
    ros-foxy-slam-toolbox \
    ros-foxy-robot-state-publisher \
    ros-foxy-xacro \
    ros-foxy-image-transport \
    ros-foxy-interactive-markers \
    && apt clean

RUN apt update && apt install -y \
    ros-foxy-turtlebot3-msgs \
    ros-foxy-turtlebot3 \
    ros-foxy-turtlebot3-simulations \
    ros-foxy-turtlebot3-navigation2 \
    ros-foxy-turtlebot3-cartographer \
    ros-foxy-dynamixel-sdk \
    ros-foxy-gazebo-ros-pkgs 
RUN apt install -y ros-foxy-desktop

RUN rosdep init && rosdep update

RUN curl -ssL http://get.gazebosim.org | sh

# Create workspace and clone TurtleBot3 repositories
RUN mkdir -p /turtlebot3_ws/src
WORKDIR /turtlebot3_ws/src

# Clone TurtleBot3 packages
RUN git clone -b foxy-devel https://github.com/ROBOTIS-GIT/turtlebot3.git && \
    git clone -b foxy-devel https://github.com/ROBOTIS-GIT/turtlebot3_simulations.git

RUN apt update && apt install -y ros-foxy-dynamixel-sdk

# Build the workspace with colcon
WORKDIR /turtlebot3_ws
RUN /bin/bash -c "source /opt/ros/foxy/setup.bash; colcon build"

# Source environments
RUN echo "source /opt/ros/foxy/setup.bash" >> /root/.bashrc && \
    echo "source /turtlebot3_ws/install/setup.bash" >> /root/.bashrc && \
    echo "export TURTLEBOT3_MODEL=burger" >> /root/.bashrc

# Cleanup
RUN rm -rf /var/lib/apt/lists/*

# Add entrypoint
ADD entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# Entrypoint and workspace
WORKDIR /turtlebot3_ws
ENTRYPOINT [ "/entrypoint.sh" ]