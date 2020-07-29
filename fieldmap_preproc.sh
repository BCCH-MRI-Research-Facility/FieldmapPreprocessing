#! bin/bash
# Author: Lynne Williams
# July 28, 2020 16:43:04 PDT
#
# fieldmap_preproc.sh splits the 2 volume 
# b0map outputs from the GE Discovery scanner,
# renames them to BIDS convention, and adds
# the original fieldmap files to the .bidsignore
# file. Note: (1) the 2 volumes consist of a 
# precomputed fieldmap and a magnitude image.
# (2) The script will loop through all subjects 
# in the BIDS root directory.
#
# USAGE:
# bash fieldmap_preproc.sh <BIDS root directory> `pwd`
#
# OUTPUT:
# - sub-<subjectid>_acq-b0map-split_fieldmap.nii.gz
# - sub-<subjectid>_acq-b0map-split_fieldmap.json
# - sub-<subjectid>_acq-b0map-split_magnitude.nii.gz



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

  # remove any previously split files from the directory
  rm *split*
  
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
  for (( i=0; i<$length; i++ ))
  do 
    echo "++ ${strings[$i]}" 

    # split the file into its 2 volumes
    fslsplit ${strings[$i]}

    # break the string apart and assign it to an array
    IFS='_' read -r -a array <<< "${strings[$i]}"

    # copy the files to their correct BIDS naming conventions 
    # (using AFNI to keep the history)

    # get the run number
    printf -v run "%02d" $(( $i + 1 ))

    # write the nifti files
    3dcopy vol0000.nii.gz \
           ${array[0]}_${array[1]}-split_run-${run}_fieldmap.nii.gz
    3dcopy vol0001.nii.gz \
           ${array[0]}_${array[1]}-split_run-${run}_magnitude.nii.gz

    # and copy the json file to the new name
    cp ${strings[$i]%.nii.gz}.json \
       ${array[0]}_${array[1]}-split_run-${run}_fieldmap.json
  
    # now remove the wrongly named files
    rm vol000*

    # Now append the original fieldmap and json to the bidsignore file
    echo ${strings[$i]} >> ${1}/.bidsignore
    echo ${strings[$i]%.nii.gz}.json >> ${1}/.bidsignore
  done

  # go back to the base directory
  cd ${1}

done

# go back to the directory you started in
cd ${2}

echo "All done!"
