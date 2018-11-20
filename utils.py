from os.path import join as pjoin
import numpy as np
import nibabel as nib

import tarfile
import zipfile
from dipy.core.gradients import gradient_table
from dipy.io.gradients import read_bvals_bvecs
def read_data(folder):
    """ Load HCP dataset

    Returns
    -------
    img : obj,
        Nifti1Image
    gtab : obj,
        GradientTable
    """
    
    fraw = pjoin(folder, 'data.nii.gz')
    fbval = pjoin(folder, 'bvals')
    fbvec = pjoin(folder, 'bvecs')
    bvals, bvecs = read_bvals_bvecs(fbval, fbvec)
    gtab = gradient_table(bvals, bvecs)
    img = nib.load(fraw)
    return img, gtab
