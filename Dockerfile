FROM ubuntu:20.04

# Set default Geographic area & Time zone with noninteractive.
ENV DEBIAN_FRONTEND noninteractive
RUN apt update \
    # Common command tools(Optional)
    && apt install -y curl tree vim \
    # Base build tools
    && apt install -y git wget unzip make gcc g++ \
    # Install Python 3.8 as Default
    && apt install -y python3.8 python3-distutils python3-pip \
    && ln -s /usr/bin/python3 /usr/bin/python \
    && python --version && pip --version \
    # Set default Geographic area & Time zone
    && apt install -y tzdata \
    && ln -fs /usr/share/zoneinfo/Asia/Shanghai /etc/localtime \
    && dpkg-reconfigure -f noninteractive tzdata \
    # cmake the antlr4-cpp-runtime dependent packages
    && apt install -y pkg-config uuid-dev \
    # Install OpenJDK 11
    && apt -y install openjdk-11-jdk \
    # Cmake install
    && wget https://github.com/Kitware/CMake/releases/download/v3.21.2/cmake-3.21.2-linux-x86_64.tar.gz \
    && tar zxvf /cmake-3.21.2-linux-x86_64.tar.gz \
    && mv /cmake-3.21.2-linux-x86_64 /opt/cmake-3.21.2 \
    && ln -sf /opt/cmake-3.21.2/bin/* /usr/bin/ \
    && rm /cmake-3.21.2-linux-x86_64.tar.gz \
    # Install antlr
    && wget https://www.antlr.org/download/antlr-4.9.2-complete.jar \
    && mv antlr-4.9.2-complete.jar /usr/local/bin/ \
    # Install antlr cpp runtime
    && wget https://www.antlr.org/download/antlr4-cpp-runtime-4.9.2-source.zip \
    && mkdir antlr4-cpp-runtime-4.9.2 && cd antlr4-cpp-runtime-4.9.2 \
    && unzip /antlr4-cpp-runtime-4.9.2-source.zip \
    && mkdir build && cd build \
    && cmake -DCMAKE_INSTALL_PREFIX=/usr/local -DANTLR4_INSTALL=ON .. \
    && make && make install \
    && rm -fr /antlr4-cpp-runtime-4.9.2-source.zip /antlr4-cpp-runtime-4.9.2 \
    # Clearup
    && rm -rf /var/lib/apt/lists/*

# Export Java relative path
ENV JAVA_HOME=/usr/lib/jvm/java-1.11.0-openjdk-amd64
ENV JRE_HOME=${JAVA_HOME}/jre
ENV CLASSPATH=.:${JAVA_HOME}/lib:${JRE_HOME}/lib:/root/bin/antlr-4.9.2-complete.jar
ENV PATH="${JAVA_HOME}/bin:${PATH}"

# # Clone and build LLVM project
RUN git clone https://github.com/llvm/llvm-project.git
#  \
#     && cd llvm-project \
#     && mkdir build && cd build \
#     && cmake -DLLVM_TARGETS_TO_BUILD=host -DLLVM_ENABLE_PROJECTS=mlir -DLLVM_ENABLE_RTTI=ON -DLLVM_ENABLE_EH=ON -DBUILD_SHARED_LIBS=ON -DCMAKE_LINKER=/usr/bin/ld.gold -DCMAKE_EXPORT_COMPILE_COMMANDS=ON ../llvm \
#     && make \
#     && make install


# # Export LLVM project relative path
# ENV LLVM_PROJECT_PATH=/llvm-project
# ENV PATH="$LLVM_PROJECT_PATH/build/bin:${PATH}"  
# ENV LIBRARY_PATH=$LLVM_PROJECT_PATH/build/lib
# ENV LD_LIBRARY_PATH=$LLVM_PROJECT_PATH/build/lib
# ENV LLVM_SYMBOLIZER_PATH=$LLVM_PROJECT_PATH/build/bin/llvm-symbolizer


VOLUME [ "/llvm-project" ]
