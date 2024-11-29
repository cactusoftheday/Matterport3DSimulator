
# Matterport3DSimulator
# Requires nvidia gpu with driver 396.37 or higher

FROM nvidia/cudagl:11.1-devel-ubuntu18.04

# Install cudnn
ENV CUDNN_VERSION 7.6.4.38
LABEL com.nvidia.cudnn.version="${CUDNN_VERSION}"

RUN rm /etc/apt/sources.list.d/cuda.list
RUN rm /etc/apt/sources.list.d/nvidia-ml.list

# Install a few libraries to support both EGL and OSMESA options
ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update && apt-get install -y wget doxygen curl libjsoncpp-dev libepoxy-dev libglm-dev libosmesa6 libosmesa6-dev libglew-dev libopencv-dev python-opencv python3-setuptools python3-dev python3-pip libgl1-mesa-dev git libgtkglext1 libgtkglext1-dev vim libcanberra-gtk3-dev libgtk-3-dev libcanberra-gtk3-module mesa-utils
RUN pip3 install torch==1.1.0 torchvision==0.3.0 numpy==1.13.3 pandas==0.24.1 networkx==2.2
RUN mkdir -p /usr/lib/x86_64-linux-gnu/gtkglext-1.0/include
RUN ln -s /usr/include/gtkglext-1.0 /usr/lib/x86_64-linux-gnu/gtkglext-1.0/include
#install latest cmake
ADD https://cmake.org/files/v3.12/cmake-3.12.2-Linux-x86_64.sh /cmake-3.12.2-Linux-x86_64.sh
RUN mkdir /opt/cmake
RUN sh /cmake-3.12.2-Linux-x86_64.sh --prefix=/opt/cmake --skip-license
RUN ln -s /opt/cmake/bin/cmake /usr/local/bin/cmake
RUN cmake --version
# Clone the OpenCV and OpenCV Contrib repositories
WORKDIR /opt
RUN git clone https://github.com/opencv/opencv.git
RUN git clone https://github.com/opencv/opencv_contrib.git 
# Build OpenCV with OpenGL support
WORKDIR /opt/opencv/build
RUN cmake -D CMAKE_BUILD_TYPE=Release \
      -D CMAKE_INSTALL_PREFIX=/usr/local \
      -D OPENCV_EXTRA_MODULES_PATH=/opt/opencv_contrib/modules \
      -D WITH_OPENGL=ON \
      -D WITH_GTK=ON \
      -D WITH_GTK_2_X=OFF \
      -D BUILD_EXAMPLES=OFF \
      -D BUILD_opencv_python3=ON \
      -D PYTHON3_EXECUTABLE=$(which python3) \
      ..

# Compile and install OpenCV
RUN make -j$(nproc) && make install && ldconfig

ENV PYTHONPATH=/root/mount/Matterport3DSimulator/build:/usr/local/lib/python3.6/site-packages/cv2/python-3.6

