#include <iostream>
#include <filesystem>
#include <opencv2/core.hpp>
#include <opencv2/imgproc.hpp>
#include <opencv2/imgcodecs.hpp>
#include <nppi.h>
#include <Exceptions.h>
#include <ImageIO.h>
#include <ImagesCPU.h>
#include <ImagesNPP.h>

namespace fs = std::filesystem;

void resizeImage(const std::string &inputPath, const std::string &outputPath, int targetWidth, int targetHeight)
{
    // declare a host image object 
    npp::ImageCPU_8u_C1 oHostSrc;
    // load image from disk
    npp::loadImage(inputPath, oHostSrc);
    // declare a device image and copy construct from the host image,
    // i.e. upload host to device
    npp::ImageNPP_8u_C1 oDeviceSrc(oHostSrc);

    // Resize output dimensions
    int newWidth = targetWidth;
    int newHeight = targetHeight;

    // Prepare source and destination sizes for NPP
    NppiSize srcSize = {(int)oDeviceSrc.width(), (int)oDeviceSrc.height()};
    NppiSize dstSize = {newWidth, newHeight};

    // Allocate memory for the resized image on the device
    npp::ImageNPP_8u_C1 oDeviceDst(dstSize.width, dstSize.height);

    // Define the region of interest (ROI) for both source and destination images
    NppiRect srcRect = {0, 0, srcSize.width, srcSize.height};
    NppiRect dstRect = {0, 0, dstSize.width, dstSize.height};

    // Perform resizing using NPP (Lanczos interpolation)
    NppStatus status = nppiResize_8u_C1R(
        oDeviceSrc.data(), oDeviceSrc.pitch(),              // Input image and step
        srcSize,                                            // Source size
        srcRect,                                            // Source ROI
        oDeviceDst.data(), oDeviceDst.pitch(),              // Output image and step
        dstSize,                                            // Destination size
        dstRect,                                            // Destination ROI
        NPPI_INTER_LANCZOS                                  // Interpolation type
    );

    if (status != NPP_SUCCESS)
    {
        std::cerr << "NPP resize failed!" << std::endl;
        return;
    }

    // declare a host image for the result
    npp::ImageCPU_8u_C1 oHostDst(oDeviceDst.size());
    // and copy the device result data into it
    oDeviceDst.copyTo(oHostDst.data(), oHostDst.pitch());

    saveImage(outputPath, oHostDst);

    nppiFree(oDeviceSrc.data());
    nppiFree(oDeviceDst.data());
}

int main(int argc, char *argv[])
{
    if (argc != 5)
    {
        std::cerr << "Usage: " << argv[0] << " <input_directory> <output_directory> <width> <height>" << std::endl;
        return -1;
    }

    std::string inputDir = argv[1];        // Input directory for images
    std::string outputDir = argv[2];       // Output directory to save processed images
    int targetWidth = std::stoi(argv[3]);  // Target width for resizing
    int targetHeight = std::stoi(argv[4]); // Target height for resizing

    // Check if input directory exists
    if (!fs::exists(inputDir) || !fs::is_directory(inputDir))
    {
        std::cerr << "Input directory does not exist or is not a directory." << std::endl;
        return -1;
    }

    // Check if output directory exists, create it if it doesn't
    if (!fs::exists(outputDir))
    {
        std::cerr << "Output directory does not exist. Creating it..." << std::endl;
        fs::create_directory(outputDir);
    }

    // Iterate over all files in the input directory
    for (const auto &entry : fs::directory_iterator(inputDir))
    {
        if (entry.is_regular_file() &&
            (entry.path().extension() == ".jpg" ||
             entry.path().extension() == ".png" ||
             entry.path().extension() == ".tiff" ||
             entry.path().extension() == ".tif"))
        {
            std::string inputImagePath = entry.path().string();
            std::string outputImagePath = outputDir + "/" + entry.path().filename().string();

            // Process the image by resizing it
            resizeImage(inputImagePath, outputImagePath, targetWidth, targetHeight);
        }
    }

    std::cout << "Processing complete." << std::endl;
    return 0;
}