#!/usr/bin/env bash

# This script converts tifs to jpgs. It works in a nested directory structure
# where microscope runs are separated into 24 directories, one for each well 
# in a 24-well plate. The script is run by a slurm array that navigates to a 
# directory and runs the script inside. It then saves the processed images to
# the following hard-coded location:

output_dir='/xdisk/rpalaniv/cedar/image_processing/stabilized_jpgs/'

# Getting the image sequence basename

# Two directories above the one where it will land, because the non-stab 
# name is two up.
sequence_name=${PWD%/*/*}


