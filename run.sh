#!/usr/bin/env bash
make clean build

make run ARGS="input_images output_images 128 128"
