# NPP Image Resizer

This program uses NVIDIA's **NPP (NVIDIA Performance Primitives)** library to resize images efficiently on the GPU. It supports grayscale images and utilizes Lanczos interpolation for high-quality resizing.

## Features
- Resizes images using GPU acceleration with NPP.
- Supports common image formats such as `.jpg`, `.png`, and `.tiff`.
- Handles batch processing of images in a directory.
- Outputs resized images to a specified directory.

## Prerequisites

Before running the program, ensure the following prerequisites are met:

1. **NVIDIA GPU**: The program requires a GPU that supports CUDA.
2. **CUDA Toolkit**: Install the [CUDA Toolkit](https://developer.nvidia.com/cuda-downloads), including the NPP library.
3. **FreeImage Library**: The program uses FreeImage for reading and writing images.
    - Install FreeImage on Linux:
     ```bash
     sudo apt-get install libfreeimage-dev
     ```
4. **NVIDIA Compiler (`nvcc`)**: The program requires the NVIDIA Compiler for building.
5. **Make**: Ensure `make` is installed for building the program.

## Installation

1. Clone this repository:
   ```bash
   git clone https://github.com/seungillee/gpu-sip
   cd gpu-sip
   ```

2. Build the program

```bash
make build
make run ARGS="input_images output_images 128 128"
```

## Usage

The program processes all images in a specified input directory and saves the resized versions to an output directory.

### Command-Line Syntax

```bash
./resize_images.exe <input_directory> <output_directory> <width> <height>
```

### Arguments
* \<input_directory\>: Path to the directory containing the input images.
* \<output_directory\>: Path to the directory where resized images will be saved.
* \<width\>: Target width of the resized images.
* \<height\>: Target height of the resized images.

### Example
```bash
./resize_images.exe ./input_images ./output_images 128 128
```
This command processes all images in the images directory, resizes them to 128x128, and saves them to the resized_images directory.

## Supported Image Formats

The following image formats are supported:
	•	.jpg
	•	.png
	•	.tiff


## Known Limitations
* Only supports grayscale images due to the use of npp::ImageCPU_8u_C1.
* Input images must be readable by the FreeImage library.
* Output images are png format

## Acknowledgements
* NVIDIA for the NPP library.
* FreeImage library for image handling.
