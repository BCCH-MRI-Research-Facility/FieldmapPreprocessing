---
title: B<sub>0</sub> Unwarping
author: "Danny Kim & Lynne Williams"
date: "2020-07-31"
---

# Fieldmap Preprocessing
The script takes in a 2 volume GE b<sub>0</sub> fieldmap file and returns a single volume fieldmap and a magnitude file in BIDS format. Data must be in BIDS format prior to running!!

## Steps:
* When in BIDS format, the filename should look something like `sub-<subjid>_acq-b0map_fieldmap.nii.gz` with its corresponding `json` file `sub-<subjid>_acq-b0map_fieldmap.json`.

*	split GRE nifti into magnitiude and phase difference image (`fslsplit GRE.nii.gz, vol0000 = phase-difference, vol0001 = magnitude, rename vol0000=phase, rename vol0001=mag)

•	brain extract magnitude image (bet mag mag_brain -R -m, output=mag_brain, mag_brain_mask)

•	erode mag_brain_mask (fslmaths mag_brain_mask -kernel gauss FWHM -ero mag_brain_mask
**choose FWHM between 1-3 mm appropriately so that mask is slightly smaller than the brain image**

•	remask mag.nii.gz with eroded brain mask (fslmaths mag - mas mag_brain_mask mag_brain)

•	The phase difference image is in units of Hz, and is phase-wrapped. To unwrap, normalize phase difference image to [-pi,pi] range (fslmaths phase -mul 3.1415 -div dTEinv phase_rad)
**dTEinv is inverse of the TE difference (in ms) in the GRE sequence. Usually dTEinv = 217 **

•	phase_rad is now in units of radians. Unwrap phase_rad using FSL PRELUDE (prelude -a mag -p phase_rad -o phase_rad_unwrapped

•	convert phase_rad_unwrapped into rad/s units (fslmaths phase_rad_unwrapped -mul dTEinv phase_rad_unwrapped_rps)

•	regularlize phase_rad_unwrapped_rps using FUGUE (fugue --loadfmap=phase_rad_unwrapped_rps.nii.gz -s FWHM --savefmap=fieldmap.nii.gz). As a note, different regularization methods exists within FUGUE.

•	load feat_gui or melodic_ica_gui, and setup prestats B0 unwarping option with:
- Fieldmap=fieldmap.nii.gz
- Fieldmap map=mag_brain.nii.gz
- Effective EPI echo spacing=EPI’s time between successive k-space lines (in ms)
- EPI TE=EPI’s TE (in ms)
- Unwarp direction=+phase-encoding direction (for axial EPI=+y)
%Signal Loss Threshold=10

•	Make sure feat’s registration step has:
- Main Structural Image=Non-uniformity corrected, brain extracted high-res structural with naming convention T1_brain for brain extracted T1 (both T1 and T1_brain must exist)
- Registration Method is BBR







```
fieldmap_preproc.sh splits the 2 volume 
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
# - sub-<subjectid>_acq-b0mapsplit<_run-01>_fieldmap.nii.gz
# - sub-<subjectid>_acq-b0mapsplit<_run-01>_fieldmap.json
# - sub-<subjectid>_acq-b0mapsplit<_run-01>_magnitude.nii.gz
```
