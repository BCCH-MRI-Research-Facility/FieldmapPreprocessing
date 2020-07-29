# FieldmapPreprocessing
The script takes in a 2 volume GE b<sub>0</sub> fieldmap file and returns a single volume fieldmap and a magnitude file in BIDS format. Data must be in BIDS format prior to running!!

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
