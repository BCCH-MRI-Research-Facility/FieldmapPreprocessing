#! bin/bash
# Author: Lynne Williams
# July 28, 2020 16:43:04 PDT
#
# UPDATED: August 3, 2020 17:31:39 PDT
#          July 31, 2020 10:18:40 PDT
#
# Licensed under CC0 1.0
#
# fieldmap_preproc.sh splits the 2 volume 
# b0map outputs from the GE Discovery scanner,
# renames them to BIDS convention, and adds
# the original fieldmap files to the .bidsignore
# file. Note: (1) the 2 volumes consist of a 
# phasedifference map and a magnitude image.
# (2) The script will loop through all subjects 
# in the BIDS root directory, but will skip already
# preprocessed fieldmaps unless the overwrite flag is
# given. Then it will recompute all fieldmaps in your
# BIDS directory.
#
# USAGE:
# bash fieldmap_preproc.sh <BIDS root directory> `pwd` [overwrite]
#
# OUTPUT:
# - sub-<subjectid>_acq-b0map-split_fieldmap.nii.gz
# - sub-<subjectid>_acq-b0map-split_fieldmap.json
# - sub-<subjectid>_acq-b0map-split_magnitude.nii.gz


# set dTEinv and FWHM.  Check your data and set these 
# to appropriate values for your data.
dTEinv=217 # dTEinv is inverse of the TE difference (in ms) in the GRE sequence
FWHM=3 # set width of kernel for erroding the brain mask (should be between 1 and 3 mm)

# change directories into the root of your BIDS directory
# get the base directory path
cd ${1}


for subject in `ls -d sub-*`
do

  echo Running ${subject}

  # Make sure we are in the base directory
  cd ${1}

  # Change directories into the fmap directory
  cd ./${subject}/fmap/

  # remove and reprocess split files on request
  if [ -n "${3}" ]
  then
    # remove any previously split files from the directory
    rm *split*
  fi

  # Check if proper fieldmaps exist
  if [ ! -f *_magnitude.nii.gz ]
  then
  
    # get the nifti file(s) for the fieldmap(s)
    string=`echo sub*_fieldmap.nii.gz`

    # check the length of the string(s) and 
    # loop through multiple fieldmaps,
    # if necessary

    # get the length of the string array
    IFS=' ' read -r -a strings <<< "${string}"
  
    length=${#strings[@]}

    # loop through the strings (this will catch 
    # when there is more than one fieldmap in 
    # the fmap directory)
       
  fi

  # go back to the base directory
  cd ${1}

done

# go back to the directory you started in
cd ${2}

echo "All done!"
