# Directories and flags for OpenCV and NPP
IDIR=./
CXX = nvcc

# OpenCV and NPP include and library flags
INCLUDES += -I./UtilNPP
CXXFLAGS += $(shell pkg-config --cflags --libs opencv4)
LDFLAGS += $(shell pkg-config --libs --static opencv)
LDFLAGS += -L/usr/local/cuda/lib64 -lnppisu_static -lnppif_static -lnppc_static -lculibos -lfreeimage -lnppig_static -lculibos # Link against NPP libraries

# Build target
all: clean build

build: resize_images.cu
	$(CXX) resize_images.cu --std=c++17 `pkg-config opencv --cflags --libs` -o resize_images.exe -Wno-deprecated-gpu-targets $(CXXFLAGS) -I/usr/local/cuda/include $(INCLUDES) $(LDFLAGS) -lcuda

# Run target
run:
	./resize_images.exe $(ARGS)

# Clean target
clean:
	rm -f resize_images.exe output_images/*