# NiftyRegSGD

Currently, non-rigid image registration algorithms are too computationally intensive to use in time-critical ap-plications.
NiftyRegSGD is a high performance implementation of non-rigid B-spline registration using stochastic gradient descent on GPU. This work is an extension of NiftyReg 1.3.9. This work is done as my master thesis at TU Delft and to download my thesis and paper, use [this link](https://repository.tudelft.nl/islandora/object/uuid%3A740d4ebd-2436-4b1a-a8db-cb1e0d56a980). The following paper discusses NiftyRegSGD.

>P. Bhosale, M. Staring, Z. Al-Ars, and F. F. Berendsen, “GPU-based stochastic- gradient optimization for non-rigid medical image registration in time-critical applications,” SPIE on Medical Imaging, to appear in Feb 2018

To install NiftyRegSGD, follow the similar instructions on [this link](http://cmictig.cs.ucl.ac.uk/wiki/index.php/NiftyReg_install)

Command-line example

> reg_f3d -ref baseline_1_crop.nii -flo followup_1_crop.nii -res p000_Aard_out.nii -aff affine_matrix_p000_Aard_1.txt -cpp p000_Aard_cpp.nii -rdmsam 1 -maxit 100 -SGD 0.25 20 0.9 -noConj -ln 3 -gpu

- ref = fixed or reference image
- flo = floting or moving image 
- res = ouput aligned image 
- aff = input affine parameters 
- res = output aligned image 
- cpp = output control point image
- rdmsam = sampling percentage
- SGD = [a, A and alpha] for decaying step size
- noConj = not to use conjugate gradient
- ln = number of resolutions
- gpu = use GPGPU
