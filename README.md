---
title: B<sub>0</sub> Unwarping
author: "Danny Kim & Lynne Williams"
date: "2020-07-31"
---

## Requirements
- `bash` shell (Note: `zsh` is now the shell for `MAC OS`, you will need to switch to bash to use the code)
- `FSL` v6.0 or above

If you use this script, please be sure to cite its dependencies:
### FSL
1. M.W. Woolrich, S. Jbabdi, B. Patenaude, M. Chappell, S. Makni, T. Behrens, C. Beckmann, M. Jenkinson, S.M. Smith. Bayesian analysis of neuroimaging data in FSL. NeuroImage, 45:S173-86, 2009

2. S.M. Smith, M. Jenkinson, M.W. Woolrich, C.F. Beckmann, T.E.J. Behrens, H. Johansen-Berg, P.R. Bannister, M. De Luca, I. Drobnjak, D.E. Flitney, R. Niazy, J. Saunders, J. Vickers, Y. Zhang, N. De Stefano, J.M. Brady, and P.M. Matthews. Advances in functional and structural MR image analysis and implementation as FSL. NeuroImage, 23(S1):208-19, 2004

3. M. Jenkinson, C.F. Beckmann, T.E. Behrens, M.W. Woolrich, S.M. Smith. FSL. NeuroImage, 62:782-90, 2012 


## B<sub>0</sub> Fieldmap Preprocessing
The script takes in a 2 volume GE b<sub>0</sub> fieldmap file (which is not a regularized fieldmap on our BCCH MRI Research Facility 3T Discovery) and returns a single volume regularized fieldmap and a magnitude file in BIDS format. Data must be in BIDS format prior to running!! See the [Brain Imaging Data Structure (BIDS) Standard](https://bids.neuroimaging.io/) to format your data directory and naming structure.

### BIDS Formatting of the original BCCH MRI Research Facility GE scanner output
* When in BIDS format, the filename should look something like `sub-<subjid>_acq-b0map_fieldmap.nii.gz` with its corresponding `json` file `sub-<subjid>_acq-b0map_fieldmap.json`. Use the online [BIDS validator](https://bids-standard.github.io/bids-validator/) at [https://bids-standard.github.io/bids-validator/](https://bids-standard.github.io/bids-validator/) to verify your BIDS formatting before starting.

## Usage
Open a terminal window. If not already in a bash shell, switch shells:
```
chsh bash
```

To use the shell script enter the following into a `bash` shell from the directory where you stored the Fieldmap Preprocessing `.sh` file:

```
bash fieldmap_preproc.sh <BIDS root directory> `pwd`
```

The script will write the new files to the `fmap` directory for each subject and enter the original two volume map into the `.bidsignore` file so that any BIDS derived software (e.g., `MRIQC`, `fMRIprep`) will not pick it up by accident.

## Now you are ready for `fMRIprep` or `FSL` processing
### If using `fMRIprep`([https://fmriprep.org/en/latest/usage.html](https://fmriprep.org/en/latest/usage.html))
You are ready to go.  Make sure the new files are in the `fmap` folder. Use your usual `fmriprep-docker` command to get things going.

### If using `FSL`
Load `feat_gui` or `melodic_ica_gui`, and setup prestats B<sub>0</sub> unwarping option with:
* Fieldmap = `sub-<subjid>_acq-b0mapsplit_run-<0?>_fieldmap.nii.gz`
* Fieldmap map = `sub-<subjid>_acq-b0mapsplit_run-<0?>_magnitude.nii.gz`
* Effective EPI echo spacing = EPI’s time between successive k-space lines (in ms). You can find this in the corresponding `.json` file
* EPI TE = EPI’s TE (in ms). Again, find the value in the corresponding `.json` file
* Unwarp direction = `+phase-encoding direction` (for axial EPI=+y)
* %Signal Loss Threshold = `10`

#### If using FEAT
Make sure `feat`’s registration step has:
* Main Structural Image=Non-uniformity corrected, brain extracted high-res structural with naming convention T1_brain for brain extracted T1 (both T1 and T1_brain must exist)
* Registration Method is BBR


```
fieldmap_preproc.sh splits the 2 volume 
# b0map outputs from the GE Discovery scanner,
# renames them to BIDS convention, and adds
# the original fieldmap files to the .bidsignore
# file. Note: (1) the original 2 volumes consist of a 
# phase-difference map and a magnitude image.
# (2) The script will loop through all subjects 
# in the BIDS root directory. 
#
# USAGE:
# bash fieldmap_preproc.sh <BIDS root directory> `pwd`
#
# OUTPUT:
# A regularized fieldmap: sub-<subjectid>_acq-b0mapsplit<_run-01>_fieldmap.nii.gz 
# A corresponding json file: sub-<subjectid>_acq-b0mapsplit<_run-01>_fieldmap.json
# A magnitude image: sub-<subjectid>_acq-b0mapsplit<_run-01>_magnitude.nii.gz
```
