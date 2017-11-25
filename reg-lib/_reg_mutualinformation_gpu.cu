/*
 *  _reg_mutualinformation_gpu.cu
 *
 *
 *  Created by Marc Modat on 24/03/2009.
 *  Copyright (c) 2009, University College London. All rights reserved.
 *  Centre for Medical Image Computing (CMIC)
 *  See the LICENSE.txt file in the nifty_reg root folder
 *
 */

#ifndef _REG_MUTUALINFORMATION_GPU_CU
#define _REG_MUTUALINFORMATION_GPU_CU

#include "_reg_blocksize_gpu.h"
#include "_reg_mutualinformation_gpu.h"
#include "_reg_mutualinformation.h"
#include "_reg_tools.h"
#include "_reg_mutualinformation_kernels.cu"
#include <iostream>
#include <sys/time.h>


double GetBasisSplineValue(double x)
{
    x=fabs(x);
    double value=0.0;
    if(x<2.0){
        if(x<1.0)
            value = (double)(2.0f/3.0f + (0.5f*x-1.0)*x*x);
        else{
            x-=2.0f;
            value = -x*x*x/6.0f;
        }
    }
    return value;
}
//template<class double>
void sum_axes(int axes, int current, double *histogram, double *&sums,
              int num_dims, int *dimensions, int *indices)
{
    int index;
    double value = (double)0;

    for(indices[current] = 0; indices[current] < dimensions[current]; ++indices[current])
    {
        if(axes == current) {
            index = calculate_index(num_dims, dimensions, indices);
            value += histogram[index];
        }
        else {
            sum_axes(axes, previous(current, num_dims), histogram,
                                    sums, num_dims, dimensions, indices);
        }
    }
    // Store the sum along the current line and increment the storage pointer
    if (axes == current)
    {
        *(sums) = value;
        ++sums;
    }
}
void smooth_axes(int axes, int current, double *histogram,
                 double *result, double *window,
                 int num_dims, int *dimensions, int *indices)
{
    int temp, index;
    double value;
    for(indices[current] = 0; indices[current] < dimensions[current]; ++indices[current])
    {
        if(axes == current) {
            temp = indices[current];
            indices[current]--;
            value = (double)0;
            for(int it=0; it<3; it++) {
                if(-1<indices[current] && indices[current]<dimensions[current]) {
                    index = calculate_index(num_dims, dimensions, indices);
                    value += histogram[index] * window[it];
                }
                indices[current]++;
            }
            indices[current] = temp;
            index = calculate_index(num_dims, dimensions, indices);
            result[index] = value;
        }
        else {
            smooth_axes(axes, previous(current, num_dims), histogram,
                                       result, window, num_dims, dimensions, indices);
        }
    }
}

/// Traverse the histogram along the specified axes and smooth along it
//template<class double>
void traverse_and_smooth_axes(int axes, double *histogram,
                              double *result, double *window,
                              int num_dims, int *dimensions)
{
    int indices[num_dims];
    for(int dim = 0; dim < num_dims; ++dim) indices[dim] = 0;

    smooth_axes(axes, previous(axes, num_dims), histogram,
                               result, window, num_dims, dimensions, indices);
}

/// Sum along the specified axes. Uses recursion


/// Traverse and sum along an axes
//template<class double>
void traverse_and_sum_axes(int axes, double *histogram, double *&sums,
                           int num_dims, int *dimensions)
{
    int indices[num_dims];
    for(int dim = 0; dim < num_dims; ++dim) indices[dim] = 0;
    sum_axes(axes, previous(axes, num_dims), histogram, sums,
                            num_dims, dimensions, indices);
}



//new gpu getentropy function
void reg_getEntropies_gpu(nifti_image *targetImage,
                      nifti_image *resultImage,
                      unsigned int *target_bins, // should be an array of size num_target_volumes
                      unsigned int *result_bins, // should be an array of size num_result_volumes
                      double *probaJointHistogram,
                      double *logJointHistogram,
                      double *entropies,
                      int *mask,
                      bool approx,
					  float *c_targetImage,
					  float *c_resultImage,
					  int *c_mask,
					  int activeVoxelNumber)
{	

  
	//double *c_targetImage,*c_resultImage;
	//float *c_targetImage = static_cast<float *>(targetImage->data);
	//float *c_resultImage = static_cast<float *>(resultImage->data);
	
	struct timeval t1, t2,t3,t4,t5,t6;
    double elapsedTime,elapsedTime1,elapsedTime2;
	
	int *c_probaJointHistogram_int,*c_probaJointHistogram,*c_voxel_number,*voxel_number_blk;
	int num_target_volumes = targetImage->nt;
    int num_result_volumes = resultImage->nt;
	int i, j;
	int voxel_number=0;
	if(num_target_volumes>1 || num_result_volumes>1) approx=true;
	
    int targetVoxelNumber = targetImage->nx * targetImage->ny * targetImage->nz;
	//int resultVoxelNumber = resultImage->nx * resultImage->ny * resultImage->nz;
	 //fprintf(stderr,"[NiftyReg Debug parag] targetVoxelNumber= %d\n",resultVoxelNumber); 
/*     DTYPE *targetImagePtr = static_cast<DTYPE *>(targetImage->data);
    DTYPE *resultImagePtr = static_cast<DTYPE *>(resultImage->data); */

    // Build up this arrays of offsets that will help us index the histogram entries
/*     SafeArray<int> target_offsets(num_target_volumes);
    SafeArray<int> result_offsets(num_result_volumes); */
	int target_offsets[num_target_volumes];
	int result_offsets[num_result_volumes];
	
	

    int num_histogram_entries = 1;
    int total_target_entries = 1;
    int total_result_entries = 1;
	int nthreads=1024;
	int reduce_size=ceil(targetVoxelNumber/nthreads);
    // Data pointers
    int histogram_dimensions[num_target_volumes + num_result_volumes];

    // Calculate some constants and initialize the data pointers
    for (i = 0; i < num_target_volumes; ++i) {
        num_histogram_entries *= target_bins[i];
        total_target_entries *= target_bins[i];
        histogram_dimensions[i] = target_bins[i];
		/* fprintf(stderr,"[NiftyReg Debug parag] target_bins= %d\n",num_histogram_entries); */
		
        target_offsets[i] = 1;
        for (j = i; j > 0; --j) {
			//fprintf(stderr,"[NiftyReg Debug parag] j= %d\n",j);
			target_offsets[i] *= target_bins[j - 1];
			}
    }

    for (i = 0; i < num_result_volumes; ++i) {
        num_histogram_entries *= result_bins[i];
        total_result_entries *= result_bins[i];
        histogram_dimensions[num_target_volumes + i] = result_bins[i];

        result_offsets[i] = 1;
        for (j = i; j > 0; --j) result_offsets[i] *= result_bins[j-1];
    }
    int num_probabilities = num_histogram_entries;
	num_histogram_entries += total_target_entries + total_result_entries;

	c_probaJointHistogram_int = (int *)malloc(num_histogram_entries * sizeof(int));
	voxel_number_blk=(int *)malloc(reduce_size * sizeof(int));
    memset(c_probaJointHistogram_int, 0, num_histogram_entries * sizeof(int));
	memset(voxel_number_blk, 0, reduce_size * sizeof(int));
    memset(probaJointHistogram, 0, num_histogram_entries * sizeof(double));
	memset(logJointHistogram, 0, num_histogram_entries * sizeof(double));

/* 	NR_CUDA_SAFE_CALL((cudaMemcpy(mask, c_mask, targetVoxelNumber * sizeof(int), cudaMemcpyDeviceToHost)));
    // Space for storing the marginal entropies.
				for (i=0;i<targetVoxelNumber;i++)
	{
		printf("[NiftyReg Debug parag] index=%d mask=%d\n",i,mask[i]);
		
	} */
	
	 
	 // allocate and initialize an array of stream handles
 
	//allocate memory 
 	
	 gettimeofday(&t1, NULL);
	NR_CUDA_SAFE_CALL(cudaMalloc(&c_probaJointHistogram,num_histogram_entries * sizeof(int)));
	//NR_CUDA_SAFE_CALL(cudaMalloc(&c_mask,targetVoxelNumber * sizeof(int)));
	//NR_CUDA_SAFE_CALL(cudaMalloc(&c_resultImage,resultVoxelNumber * sizeof(float)));
	NR_CUDA_SAFE_CALL(cudaMalloc(&c_voxel_number,reduce_size * sizeof(int)));
	

/* 	NR_CUDA_SAFE_CALL(cudaMallocHost(&c_probaJointHistogram,num_histogram_entries * sizeof(int)));
	NR_CUDA_SAFE_CALL(cudaMallocHost(&c_targetImage,targetVoxelNumber * sizeof(float)));
	NR_CUDA_SAFE_CALL(cudaMallocHost(&c_resultImage,resultVoxelNumber * sizeof(float)));
	NR_CUDA_SAFE_CALL(cudaMallocHost(&c_voxel_number,reduce_size * sizeof(int))); */
	
	gettimeofday(&t5, NULL);
	NR_CUDA_SAFE_CALL((cudaMemcpy(c_probaJointHistogram, c_probaJointHistogram_int, num_histogram_entries * sizeof(int), cudaMemcpyHostToDevice)));
	//NR_CUDA_SAFE_CALL((cudaMemcpy(c_mask, mask, targetVoxelNumber * sizeof(int), cudaMemcpyHostToDevice)));
	//NR_CUDA_SAFE_CALL((cudaMemcpy(c_resultImage, resultImage->data, resultVoxelNumber * sizeof(float), cudaMemcpyHostToDevice)));
	NR_CUDA_SAFE_CALL(cudaBindTexture(0, maskTexture, c_mask, targetVoxelNumber*sizeof(int)));
	//NR_CUDA_SAFE_CALL((cudaMemcpy(c_voxel_number, voxel_number_blk, reduce_size * sizeof(int), cudaMemcpyHostToDevice)));
	gettimeofday(&t6, NULL);
	
	//NR_CUDA_SAFE_CALL((cudaMemcpy(c_targetVoxelNumber, &targetVoxelNumber, sizeof(int), cudaMemcpyHostToDevice)));
	dim3 G1(ceil(activeVoxelNumber/nthreads),1,1);
	dim3 B1(nthreads,1,1);
	
	int shared_size = nthreads* sizeof(int);
	shared_size += num_histogram_entries * sizeof(int);
	gettimeofday(&t3, NULL);
	//reg_getJointHistogram_kernel1<<< G1,B1,shared_size>>>(c_targetImage,c_resultImage,c_probaJointHistogram,c_voxel_number,targetVoxelNumber,total_target_entries);
	//reg_getJointHistogram_kernel2<<< G1,B1,shared_size>>>(c_targetImage,c_resultImage,c_probaJointHistogram,c_voxel_number,targetVoxelNumber,total_target_entries);
	//reg_getJointHistogram_kernel3<<< G1,B1,shared_size>>>(c_targetImage,c_resultImage,c_probaJointHistogram,c_voxel_number,targetVoxelNumber,total_target_entries);
	//reg_getJointHistogram_kernel4<<< G1,B1,shared_size>>>(c_targetImage,c_resultImage,c_probaJointHistogram,c_voxel_number,targetVoxelNumber,total_target_entries);
	reg_getJointHistogram_kernel4b<<< G1,B1>>>(c_targetImage,c_resultImage,c_probaJointHistogram,c_voxel_number,targetVoxelNumber,total_target_entries,activeVoxelNumber/* ,c_mask */);
	//reg_getJointHistogram_kernel5<<< G1,B1,shared_size>>>(c_targetImage,c_resultImage,c_probaJointHistogram,targetVoxelNumber,total_target_entries,num_histogram_entries);
	//reg_getJointHistogram_kernel6<<< G1,B1,shared_size>>>(c_targetImage,c_resultImage,c_probaJointHistogram,targetVoxelNumber,total_target_entries,num_histogram_entries);
	NR_CUDA_CHECK_KERNEL(G1,B1);
	gettimeofday(&t4, NULL);

	NR_CUDA_SAFE_CALL((cudaMemcpy(c_probaJointHistogram_int, c_probaJointHistogram, num_histogram_entries * sizeof(int), cudaMemcpyDeviceToHost)));
	//NR_CUDA_SAFE_CALL((cudaMemcpy(voxel_number_blk, c_voxel_number, reduce_size * sizeof(int), cudaMemcpyDeviceToHost)));
	   
	
		for (i=0;i<num_histogram_entries;i++)
	{
		//printf("[NiftyReg Debug parag] index=%d probaJointHistogram= %d\n",i,c_probaJointHistogram_int[i]);
		probaJointHistogram[i]=(double)c_probaJointHistogram_int[i];
		voxel_number+=c_probaJointHistogram_int[i];
	}
			for (i=0;i<reduce_size;i++)
	{
		
		voxel_number+=voxel_number_blk[i];
		
	}	
	gettimeofday(&t2, NULL);
	elapsedTime = (t2.tv_sec - t1.tv_sec) * 1000.0;      // sec to ms
    elapsedTime += (t2.tv_usec - t1.tv_usec) / 1000.0;
	elapsedTime1 = (t4.tv_sec - t3.tv_sec) * 1000.0;      // sec to ms
    elapsedTime1 += (t4.tv_usec - t3.tv_usec) / 1000.0;
	elapsedTime2 = (t6.tv_sec - t5.tv_sec) * 1000.0;      // sec to ms
    elapsedTime2 += (t6.tv_usec - t5.tv_usec) / 1000.0;
	
	//printf("[NiftyReg F3D] Total joint hist filing in GPU=%f  and kernel time=%f copyHtoD=%f msec\n", elapsedTime,elapsedTime1,elapsedTime2 );
	//printf("[NiftyReg Debug parag] size=%lu\n",targetVoxelNumber * sizeof(float));
	//cudaFree(c_mask);
	//cudaFree(c_resultImage);
	NR_CUDA_SAFE_CALL(cudaFree(c_probaJointHistogram));
	NR_CUDA_SAFE_CALL(cudaUnbindTexture(maskTexture));
/* 	cudaFreeHost(c_targetImage);
	cudaFreeHost(c_resultImage);
	cudaFreeHost(c_probaJointHistogram); */
	free(c_probaJointHistogram_int);
	free(voxel_number_blk);
	//fprintf(stderr,"[NiftyReg ERROR] The GPU implementation of new entropy calculation \n");
    

    int num_axes = num_target_volumes + num_result_volumes;
    if(approx || targetImage->nt>1 || resultImage->nt>1){
    // standard joint histogram filling has been used
    // Joint histogram has to be smoothed
        double window[3];
        window[0] = window[2] = GetBasisSplineValue((double)(-1.0));
        window[1] = GetBasisSplineValue((double)(0.0));

        double *histogram=NULL;
        double *result=NULL;

        // Smooth along each of the axes
        for (i = 0; i < num_axes; ++i)
        {
            // Use the arrays for storage of results
            if (i % 2 == 0) {
                result = logJointHistogram;
                histogram = probaJointHistogram;
            }
            else {
                result = probaJointHistogram;
                histogram = logJointHistogram;
            }
            traverse_and_smooth_axes(i, histogram, result, window,
                                             num_axes, histogram_dimensions);
        }

        // We may need to transfer the result
        if (result == logJointHistogram) memcpy(probaJointHistogram, logJointHistogram,
                                                sizeof(double)*num_probabilities);
    }// approx
	memset(logJointHistogram, 0, num_histogram_entries * sizeof(double));

    // Convert to probabilities
    for(i = 0; i < num_probabilities; ++i) {
        if (probaJointHistogram[i]) probaJointHistogram[i] /= voxel_number;
    }

    // Marginalise over all the result axes to generate the target entropy
    double *data = probaJointHistogram;
    double *store = logJointHistogram;
    double current_value, current_log;

    int count;
    double target_entropy = 0;
    {
        double scratch [num_probabilities/histogram_dimensions[num_axes - 1]];
        // marginalise over the result axes
        for (i = num_result_volumes-1, count = 0; i >= 0; --i, ++count)
        {
            traverse_and_sum_axes(num_axes - count - 1,
                                          data, store, num_axes - count,
                                          histogram_dimensions);

            if (count % 2 == 0) {
                data = logJointHistogram;
                store = scratch;
            }
            else {
                data = scratch;
                store = logJointHistogram;
            }
        }

        // Generate target entropy
        double *log_joint_target = &logJointHistogram[num_probabilities];

        for (i = 0; i < total_target_entries; ++i)
        {
            current_value = data[i];            
            current_log = 0;
            if (current_value) current_log = log(current_value);
            target_entropy -= current_value * current_log;
            log_joint_target[i] = current_log;
        }
    }
    memset(logJointHistogram, 0, num_probabilities * sizeof(double));
    data = probaJointHistogram;
    store = logJointHistogram;

    // Marginalise over the target axes
    double result_entropy = 0;
    {
        double scratch [num_probabilities / histogram_dimensions[0]];
        for (i = 0; i < num_target_volumes; ++i)
        {
            traverse_and_sum_axes(0, data, store, num_axes - i, &histogram_dimensions[i]);
            if (i % 2 == 0) {
                data = logJointHistogram;
                store = scratch;
            }
            else {
                data = scratch;
                store = logJointHistogram;
            }
        }
        // Generate result entropy
        double *log_joint_result = &logJointHistogram[num_probabilities+total_target_entries];

        for (i = 0; i < total_result_entries; ++i)
        {
            current_value = data[i];            
            current_log = 0;
            if (current_value) current_log = log(current_value);
            result_entropy -= current_value * current_log;
            log_joint_result[i] = current_log;
        }
    }

    // Generate joint entropy
    double joint_entropy = 0;
    for (i = 0; i < num_probabilities; ++i)
    {
        current_value = probaJointHistogram[i];        
        current_log = 0;
        if (current_value) current_log = log(current_value);
        joint_entropy -= current_value * current_log;
        logJointHistogram[i] = current_log;
    }

    entropies[0] = target_entropy;
    entropies[1] = result_entropy;
    entropies[2] = joint_entropy;
    entropies[3] = voxel_number;
/* 	printf("[NiftyReg Debug parag] entropies[0]=%f\n",entropies[0]);
	printf("[NiftyReg Debug parag] entropies[1]=%f\n",entropies[1]);
	printf("[NiftyReg Debug parag] entropies[2]=%f\n",entropies[2]);
	printf("[NiftyReg Debug parag] entropies[3]=%f\n",entropies[3]);
	exit(0); */
    return;

						  
}


/// Called when we have two target and two source image
void reg_getEntropies2x2_gpu(nifti_image *targetImages,
                             nifti_image *resultImages,
                             //int type,
                             unsigned int *target_bins, // should be an array of size num_target_volumes
                             unsigned int *result_bins, // should be an array of size num_result_volumes
                             double *probaJointHistogram,
                             double *logJointHistogram,
                             float  **logJointHistogram_d,
                             double *entropies,
                             int *mask)
{
    // The joint histogram is filled using the CPU arrays
    //Check the type of the target and source images
    if(targetImages->datatype!=NIFTI_TYPE_FLOAT32 || resultImages->datatype!=NIFTI_TYPE_FLOAT32){
        printf("[NiftyReg CUDA] reg_getEntropies2x2_gpu: This kernel should only be used floating images.\n");
        exit(1);
    }
    unsigned int voxelNumber = targetImages->nx*targetImages->ny*targetImages->nz;
    unsigned int binNumber = target_bins[0]*target_bins[1]*result_bins[0]*result_bins[1]+
                             target_bins[0]*target_bins[1]+result_bins[0]*result_bins[1];
    float *ref1Ptr = static_cast<float *>(targetImages->data);
    float *ref2Ptr = &ref1Ptr[voxelNumber];
    float *res1Ptr = static_cast<float *>(resultImages->data);
    float *res2Ptr = &res1Ptr[voxelNumber];
    int *maskPtr = &mask[0];
    memset(probaJointHistogram, 0, binNumber*sizeof(double));
    double voxelSum=0.;
    for(unsigned int i=0;i<voxelNumber;++i){
        if(*maskPtr++>-1){
            int val1 = static_cast<int>(*ref1Ptr);
            int val2 = static_cast<int>(*ref2Ptr);
            int val3 = static_cast<int>(*res1Ptr);
            int val4 = static_cast<int>(*res2Ptr);
            if(val1==val1 && val2==val2 && val3==val3 && val4==val4 &&
               val1>-1 && val1<(int)target_bins[0] && val2>-1 && val2<(int)target_bins[1] &&
               val3>-1 && val3<(int)result_bins[0] && val4>-1 && val4<(int)result_bins[1]){
                unsigned int index = ((val4*result_bins[0]+val3)*target_bins[1]+val2)*target_bins[0]+val1;
                probaJointHistogram[index]++;
                voxelSum++;
            }
        }
        ref1Ptr++;
        ref2Ptr++;
        res1Ptr++;
        res2Ptr++;
    }

    // The joint histogram is normalised and tranfered to the device
    float *logJointHistogram_float=NULL;
    NR_CUDA_SAFE_CALL(cudaMallocHost(&logJointHistogram_float,binNumber*sizeof(float)));
    for(unsigned int i=0;i<target_bins[0]*target_bins[1]*result_bins[0]*result_bins[1];++i)
        logJointHistogram_float[i]=float(probaJointHistogram[i]/voxelSum);

    NR_CUDA_SAFE_CALL(cudaMemcpy(*logJointHistogram_d,logJointHistogram_float,binNumber*sizeof(float),cudaMemcpyHostToDevice));
    NR_CUDA_SAFE_CALL(cudaFreeHost(logJointHistogram_float));

    float *tempHistogram=NULL;
    NR_CUDA_SAFE_CALL(cudaMalloc(&tempHistogram,binNumber*sizeof(float)));
    NR_CUDA_SAFE_CALL(cudaMemcpyToSymbol(c_firstTargetBin,&target_bins[0],sizeof(int)));
    NR_CUDA_SAFE_CALL(cudaMemcpyToSymbol(c_secondTargetBin,&target_bins[1],sizeof(int)));
    NR_CUDA_SAFE_CALL(cudaMemcpyToSymbol(c_firstResultBin,&result_bins[0],sizeof(int)));
    NR_CUDA_SAFE_CALL(cudaMemcpyToSymbol(c_secondResultBin,&result_bins[1],sizeof(int)));


    // The joint histogram is smoothed along the x axis
    NR_CUDA_SAFE_CALL(cudaBindTexture(0, histogramTexture, *logJointHistogram_d, binNumber*sizeof(float)));
    dim3 B1(Block_reg_smoothJointHistogramX,1,1);
    const int gridSizesmoothJointHistogramX=(int)ceil(sqrtf((float)(target_bins[1]*result_bins[0]*result_bins[1])/(float)B1.x));
    dim3 G1(gridSizesmoothJointHistogramX,gridSizesmoothJointHistogramX,1);
    reg_smoothJointHistogramX_kernel <<< G1, B1 >>> (tempHistogram);
    NR_CUDA_CHECK_KERNEL(G1,B1)
    NR_CUDA_SAFE_CALL(cudaUnbindTexture(histogramTexture));

    // The joint histogram is smoothed along the y axis
    NR_CUDA_SAFE_CALL(cudaBindTexture(0, histogramTexture, tempHistogram, binNumber*sizeof(float)));
    dim3 B2(Block_reg_smoothJointHistogramY,1,1);
    const int gridSizesmoothJointHistogramY=(int)ceil(sqrtf((float)(target_bins[1]*result_bins[0]*result_bins[1])/(float)B2.x));
    dim3 G2(gridSizesmoothJointHistogramY,gridSizesmoothJointHistogramY,1);
    reg_smoothJointHistogramY_kernel <<< G2, B2 >>> (*logJointHistogram_d);
    NR_CUDA_CHECK_KERNEL(G2,B2)
    NR_CUDA_SAFE_CALL(cudaUnbindTexture(histogramTexture));

    // The joint histogram is smoothed along the z axis
    NR_CUDA_SAFE_CALL(cudaBindTexture(0, histogramTexture, *logJointHistogram_d, binNumber*sizeof(float)));
    dim3 B3(Block_reg_smoothJointHistogramZ,1,1);
    const int gridSizesmoothJointHistogramZ=(int)ceil(sqrtf((float)(target_bins[1]*result_bins[0]*result_bins[1])/(float)B3.x));
    dim3 G3(gridSizesmoothJointHistogramZ,gridSizesmoothJointHistogramZ,1);
    reg_smoothJointHistogramZ_kernel <<< G3, B3 >>> (tempHistogram);
    NR_CUDA_CHECK_KERNEL(G3,B3)
    NR_CUDA_SAFE_CALL(cudaUnbindTexture(histogramTexture));

    // The joint histogram is smoothed along the w axis
    NR_CUDA_SAFE_CALL(cudaBindTexture(0, histogramTexture, tempHistogram, binNumber*sizeof(float)));
    dim3 B4(Block_reg_smoothJointHistogramW,1,1);
    const int gridSizesmoothJointHistogramW=(int)ceil(sqrtf((float)(target_bins[1]*result_bins[0]*result_bins[1])/(float)B4.x));
    dim3 G4(gridSizesmoothJointHistogramW,gridSizesmoothJointHistogramW,1);
    reg_smoothJointHistogramW_kernel <<< G4, B4 >>> (*logJointHistogram_d);
    NR_CUDA_CHECK_KERNEL(G4,B4)
    NR_CUDA_SAFE_CALL(cudaUnbindTexture(histogramTexture));

    NR_CUDA_SAFE_CALL(cudaFree(tempHistogram));
    NR_CUDA_SAFE_CALL(cudaMallocHost(&logJointHistogram_float,binNumber*sizeof(float)));
    NR_CUDA_SAFE_CALL(cudaMemcpy(logJointHistogram_float,*logJointHistogram_d,binNumber*sizeof(float),cudaMemcpyDeviceToHost));
    for(unsigned int i=0;i<target_bins[0]*target_bins[1]*result_bins[0]*result_bins[1];++i)
        probaJointHistogram[i]=logJointHistogram_float[i];
    NR_CUDA_SAFE_CALL(cudaFreeHost(logJointHistogram_float));

    // The 4D joint histogram is first marginalised along the x axis (target_bins[0])
    float *temp3DHistogram=NULL;
    NR_CUDA_SAFE_CALL(cudaMalloc(&temp3DHistogram,target_bins[1]*result_bins[0]*result_bins[1]*sizeof(float)));
    NR_CUDA_SAFE_CALL(cudaBindTexture(0, histogramTexture, *logJointHistogram_d, binNumber*sizeof(float)));
    dim3 B5(Block_reg_marginaliseTargetX,1,1);
    const int gridSizesmoothJointHistogramA=(int)ceil(sqrtf((float)(target_bins[1]*result_bins[0]*result_bins[1])/(float)B5.x));
    dim3 G5(gridSizesmoothJointHistogramA,gridSizesmoothJointHistogramA,1);
    reg_marginaliseTargetX_kernel <<< G5, B5 >>> (temp3DHistogram);
    NR_CUDA_CHECK_KERNEL(G5,B5)
    NR_CUDA_SAFE_CALL(cudaUnbindTexture(histogramTexture));

    // The 3D joint histogram is then marginalised along the y axis (target_bins[1])
    float *temp2DHistogram=NULL;
    NR_CUDA_SAFE_CALL(cudaMalloc(&temp2DHistogram,result_bins[0]*result_bins[1]*sizeof(float)));
    NR_CUDA_SAFE_CALL(cudaBindTexture(0, histogramTexture, temp3DHistogram, target_bins[1]*result_bins[0]*result_bins[1]*sizeof(float)));
    dim3 B6(Block_reg_marginaliseTargetXY,1,1);
    const int gridSizesmoothJointHistogramB=(int)ceil(sqrtf((float)(target_bins[1]*result_bins[0]*result_bins[1])/(float)B6.x));
    dim3 G6(gridSizesmoothJointHistogramB,gridSizesmoothJointHistogramB,1);
    reg_marginaliseTargetXY_kernel <<< G6, B6 >>> (temp2DHistogram);
    NR_CUDA_CHECK_KERNEL(G6,B6)
    NR_CUDA_SAFE_CALL(cudaUnbindTexture(histogramTexture));
    NR_CUDA_SAFE_CALL(cudaFree(temp3DHistogram));

    // We need to transfer it to an array of floats (cannot directly copy it to probaJointHistogram
    // as that is an array of doubles) and cudaMemcpy will produce unpredictable results
    const int total_target_entries = target_bins[0] * target_bins[1];
    const int total_result_entries = result_bins[0] * result_bins[1];
    const int num_probabilities =  total_target_entries * total_result_entries;
    int offset = num_probabilities + total_target_entries;    
    float *temp2DHistogram_h = new float[total_result_entries];
    cudaMemcpy(temp2DHistogram_h,temp2DHistogram,total_result_entries*sizeof(float), cudaMemcpyDeviceToHost);
    for (int i = 0; i < total_result_entries; ++i) {
        probaJointHistogram[offset + i] = temp2DHistogram_h[i];
    }
    delete[] temp2DHistogram_h;
    NR_CUDA_SAFE_CALL(cudaFree(temp2DHistogram));


    // Now marginalise over the result axes.
    // First over W axes. (result_bins[1])
    temp3DHistogram=NULL;
    NR_CUDA_SAFE_CALL(cudaMalloc(&temp3DHistogram, target_bins[0]*target_bins[1]*result_bins[0]*sizeof(float)));
    NR_CUDA_SAFE_CALL(cudaBindTexture(0, histogramTexture, *logJointHistogram_d, binNumber*sizeof(float)));
    dim3 B7(Block_reg_marginaliseResultX,1,1);
    const int gridSizesmoothJointHistogramC=(int)ceil(sqrtf((float)(target_bins[1]*result_bins[0]*result_bins[1])/(float)B7.x));
    dim3 G7(gridSizesmoothJointHistogramC,gridSizesmoothJointHistogramC,1);
    reg_marginaliseResultX_kernel <<< G7, B7 >>> (temp3DHistogram);
    NR_CUDA_CHECK_KERNEL(G7,B7)
    NR_CUDA_SAFE_CALL(cudaUnbindTexture(histogramTexture));

    // Now over Z axes. (result_bins[0])
    temp2DHistogram=NULL;
    NR_CUDA_SAFE_CALL(cudaMalloc(&temp2DHistogram,target_bins[0]*target_bins[1]*sizeof(float)));
    NR_CUDA_SAFE_CALL(cudaBindTexture(0, histogramTexture, temp3DHistogram, target_bins[0]*target_bins[1]*result_bins[0]*sizeof(float)));
    dim3 B8(Block_reg_marginaliseResultXY,1,1);
    const int gridSizesmoothJointHistogramD=(int)ceil(sqrtf((float)(target_bins[1]*result_bins[0]*result_bins[1])/(float)B8.x));
    dim3 G8(gridSizesmoothJointHistogramD,gridSizesmoothJointHistogramD,1);
    reg_marginaliseResultXY_kernel <<< G8, B8 >>> (temp2DHistogram);
    NR_CUDA_CHECK_KERNEL(G8,B8)
    NR_CUDA_SAFE_CALL(cudaUnbindTexture(histogramTexture));

    cudaFree(temp3DHistogram);
    // Transfer the data to CPU
    temp2DHistogram_h = new float[total_target_entries];
    cudaMemcpy(temp2DHistogram_h,temp2DHistogram,total_target_entries*sizeof(float), cudaMemcpyDeviceToHost);
    for (int i = 0; i < total_target_entries; ++i) {
        probaJointHistogram[num_probabilities + i] = temp2DHistogram_h[i];
    }    
    delete[] temp2DHistogram_h;
    cudaFree(temp2DHistogram);

    // The next bits can be put on the GPU but there is not much performance gain and it is
    // better to go the log and accumulation using double precision.

    // Generate joint entropy
    float current_value, current_log;
    double joint_entropy = 0.0;
    for (int i = 0; i < num_probabilities; ++i)
    {
        current_value = probaJointHistogram[i];
        current_log = 0.0;
        if (current_value) current_log = log(current_value);
        joint_entropy -= current_value * current_log;
        logJointHistogram[i] = current_log;
    }

    // Generate target entropy
    double *log_joint_target = &logJointHistogram[num_probabilities];
    double target_entropy = 0.0;
    for (int i = 0; i < total_target_entries; ++i)
    {
        current_value = probaJointHistogram[num_probabilities + i];
        current_log = 0.0;
        if (current_value) current_log = log(current_value);
        target_entropy -= current_value * current_log;
        log_joint_target[i] = current_log;
    }

    // Generate result entropy
    double *log_joint_result = &logJointHistogram[num_probabilities+total_target_entries];
    double result_entropy = 0.0;
    for (int i = 0; i < total_result_entries; ++i)
    {
        current_value = probaJointHistogram[num_probabilities + total_target_entries + i];
        current_log = 0.0;
        if (current_value) current_log = log(current_value);
        result_entropy -= current_value * current_log;
        log_joint_result[i] = current_log;
    }

    entropies[0] = target_entropy;
    entropies[1] = result_entropy;
    entropies[2] = joint_entropy;
    entropies[3] = voxelSum;
}

/// Called when we only have one target and one source image
void reg_getVoxelBasedNMIGradientUsingPW_gpu(   nifti_image *targetImage,
                                                nifti_image *resultImage,
                                                cudaArray **targetImageArray_d,
                                                float **resultImageArray_d,
                                                float4 **resultGradientArray_d,
                                                float **logJointHistogram_d,
                                                float4 **voxelNMIGradientArray_d,
                                                int **mask_d,
                                                int activeVoxelNumber,
                                                double *entropies,
                                                int refBinning,
                                                int floBinning)
{
    if(resultImage!=resultImage)
        printf("Useless lines to avoid a warning");

    const int voxelNumber = targetImage->nx*targetImage->ny*targetImage->nz;
    const int3 imageSize=make_int3(targetImage->nx,targetImage->ny,targetImage->nz);
    const int binNumber = refBinning*floBinning+refBinning+floBinning;
    const float4 entropies_h=make_float4((float)entropies[0],(float)entropies[1],(float)entropies[2],(float)entropies[3]);
    const float NMI = (float)((entropies[0]+entropies[1])/entropies[2]);

    // Bind Symbols
    NR_CUDA_SAFE_CALL(cudaMemcpyToSymbol(c_VoxelNumber,&voxelNumber,sizeof(int)));
    NR_CUDA_SAFE_CALL(cudaMemcpyToSymbol(c_ImageSize,&imageSize,sizeof(int3)));
    NR_CUDA_SAFE_CALL(cudaMemcpyToSymbol(c_firstTargetBin,&refBinning,sizeof(int)));
    NR_CUDA_SAFE_CALL(cudaMemcpyToSymbol(c_firstResultBin,&floBinning,sizeof(int)));
    NR_CUDA_SAFE_CALL(cudaMemcpyToSymbol(c_Entropies,&entropies_h,sizeof(float4)));
    NR_CUDA_SAFE_CALL(cudaMemcpyToSymbol(c_NMI,&NMI,sizeof(float)));
    NR_CUDA_SAFE_CALL(cudaMemcpyToSymbol(c_ActiveVoxelNumber,&activeVoxelNumber,sizeof(int)));

    // Texture bindingcurrentFloating
    //Bind target image array to a 3D texture
    firstTargetImageTexture.normalized = true;
    firstTargetImageTexture.filterMode = cudaFilterModeLinear;
    firstTargetImageTexture.addressMode[0] = cudaAddressModeWrap;
    firstTargetImageTexture.addressMode[1] = cudaAddressModeWrap;
    firstTargetImageTexture.addressMode[2] = cudaAddressModeWrap;
    cudaChannelFormatDesc channelDesc = cudaCreateChannelDesc<float>();
    NR_CUDA_SAFE_CALL(cudaBindTextureToArray(firstTargetImageTexture, *targetImageArray_d, channelDesc))
    NR_CUDA_SAFE_CALL(cudaBindTexture(0, firstResultImageTexture, *resultImageArray_d, voxelNumber*sizeof(float)));
    NR_CUDA_SAFE_CALL(cudaBindTexture(0, firstResultImageGradientTexture, *resultGradientArray_d, voxelNumber*sizeof(float4)));
    NR_CUDA_SAFE_CALL(cudaBindTexture(0, histogramTexture, *logJointHistogram_d, binNumber*sizeof(float)));
    NR_CUDA_SAFE_CALL(cudaBindTexture(0, maskTexture, *mask_d, activeVoxelNumber*sizeof(int)));
    NR_CUDA_SAFE_CALL(cudaMemset(*voxelNMIGradientArray_d, 0, voxelNumber*sizeof(float4)));

    const unsigned int Grid_reg_getVoxelBasedNMIGradientUsingPW =
        (unsigned int)ceil(sqrtf((float)activeVoxelNumber/(float)Block_reg_getVoxelBasedNMIGradientUsingPW));
    dim3 B1(Block_reg_getVoxelBasedNMIGradientUsingPW,1,1);
    dim3 G1(Grid_reg_getVoxelBasedNMIGradientUsingPW,Grid_reg_getVoxelBasedNMIGradientUsingPW,1);

    reg_getVoxelBasedNMIGradientUsingPW_kernel <<< G1, B1 >>> (*voxelNMIGradientArray_d);
    NR_CUDA_CHECK_KERNEL(G1,B1)
    NR_CUDA_SAFE_CALL(cudaUnbindTexture(firstTargetImageTexture));
    NR_CUDA_SAFE_CALL(cudaUnbindTexture(firstResultImageTexture));
    NR_CUDA_SAFE_CALL(cudaUnbindTexture(firstResultImageGradientTexture));
    NR_CUDA_SAFE_CALL(cudaUnbindTexture(histogramTexture));
    NR_CUDA_SAFE_CALL(cudaUnbindTexture(maskTexture));
}
/// Called when we have two target and two source image
void reg_getVoxelBasedNMIGradientUsingPW2x2_gpu(nifti_image *targetImage,
                                                nifti_image *resultImage,
                                                cudaArray **targetImageArray1_d,
                                                cudaArray **targetImageArray2_d,
                                                float **resultImageArray1_d,
                                                float **resultImageArray2_d,
                                                float4 **resultGradientArray1_d,
                                                float4 **resultGradientArray2_d,
                                                float **logJointHistogram_d,
                                                float4 **voxelNMIGradientArray_d,
                                                int **mask_d,
                                                int activeVoxelNumber,
                                                double *entropies,
                                                unsigned int *targetBinning,
                                                unsigned int *resultBinning)
{
    if (targetImage->nt != 2 || resultImage->nt != 2) {
        printf("[NiftyReg CUDA] reg_getVoxelBasedNMIGradientUsingPW2x2_gpu: This kernel should only be used with two target and source images\n");
        return;
    }
    const int voxelNumber = targetImage->nx*targetImage->ny*targetImage->nz;
    const int3 imageSize=make_int3(targetImage->nx,targetImage->ny,targetImage->nz);
    const float4 entropies_h=make_float4((float)entropies[0],(float)entropies[1],(float)entropies[2],(float)entropies[3]);
    const float NMI = (float)((entropies[0]+entropies[1])/entropies[2]);
    const int binNumber = targetBinning[0]*targetBinning[1]*resultBinning[0]*resultBinning[1] + (targetBinning[0]*targetBinning[1]) + (resultBinning[0]*resultBinning[1]);

    // Bind Symbols
    NR_CUDA_SAFE_CALL(cudaMemcpyToSymbol(c_VoxelNumber,&voxelNumber,sizeof(int)));
    NR_CUDA_SAFE_CALL(cudaMemcpyToSymbol(c_ImageSize,&imageSize,sizeof(int3)));
    NR_CUDA_SAFE_CALL(cudaMemcpyToSymbol(c_firstTargetBin,&targetBinning[0],sizeof(int)));
    NR_CUDA_SAFE_CALL(cudaMemcpyToSymbol(c_secondTargetBin,&targetBinning[1],sizeof(int)));
    NR_CUDA_SAFE_CALL(cudaMemcpyToSymbol(c_firstResultBin,&resultBinning[0],sizeof(int)));
    NR_CUDA_SAFE_CALL(cudaMemcpyToSymbol(c_secondResultBin,&resultBinning[1],sizeof(int)));
    NR_CUDA_SAFE_CALL(cudaMemcpyToSymbol(c_Entropies,&entropies_h,sizeof(float4)));
    NR_CUDA_SAFE_CALL(cudaMemcpyToSymbol(c_NMI,&NMI,sizeof(float)));
    NR_CUDA_SAFE_CALL(cudaMemcpyToSymbol(c_ActiveVoxelNumber,&activeVoxelNumber,sizeof(int)));

    // Texture binding
    firstTargetImageTexture.normalized = true;
    firstTargetImageTexture.filterMode = cudaFilterModeLinear;
    firstTargetImageTexture.addressMode[0] = cudaAddressModeWrap;
    firstTargetImageTexture.addressMode[1] = cudaAddressModeWrap;
    firstTargetImageTexture.addressMode[2] = cudaAddressModeWrap;
    cudaChannelFormatDesc channelDesc = cudaCreateChannelDesc<float>();
    NR_CUDA_SAFE_CALL(cudaBindTextureToArray(firstTargetImageTexture, *targetImageArray1_d, channelDesc))
    NR_CUDA_SAFE_CALL(cudaBindTextureToArray(secondTargetImageTexture, *targetImageArray2_d, channelDesc))
    NR_CUDA_SAFE_CALL(cudaBindTexture(0, firstResultImageTexture, *resultImageArray1_d, voxelNumber*sizeof(float)));
    NR_CUDA_SAFE_CALL(cudaBindTexture(0, secondResultImageTexture, *resultImageArray2_d, voxelNumber*sizeof(float)));
    NR_CUDA_SAFE_CALL(cudaBindTexture(0, firstResultImageGradientTexture, *resultGradientArray1_d, voxelNumber*sizeof(float4)));
    NR_CUDA_SAFE_CALL(cudaBindTexture(0, secondResultImageGradientTexture, *resultGradientArray2_d, voxelNumber*sizeof(float4)));
    NR_CUDA_SAFE_CALL(cudaBindTexture(0, histogramTexture, *logJointHistogram_d, binNumber*sizeof(float)));
    NR_CUDA_SAFE_CALL(cudaBindTexture(0, maskTexture, *mask_d, activeVoxelNumber*sizeof(int)));
    NR_CUDA_SAFE_CALL(cudaMemset(*voxelNMIGradientArray_d, 0, voxelNumber*sizeof(float4)));

    const unsigned int Grid_reg_getVoxelBasedNMIGradientUsingPW2x2 =
        (unsigned int)ceil(sqrtf((float)activeVoxelNumber/(float)Block_reg_getVoxelBasedNMIGradientUsingPW2x2));
    dim3 B1(Block_reg_getVoxelBasedNMIGradientUsingPW2x2,1,1);
    dim3 G1(Grid_reg_getVoxelBasedNMIGradientUsingPW2x2,Grid_reg_getVoxelBasedNMIGradientUsingPW2x2,1);

    reg_getVoxelBasedNMIGradientUsingPW2x2_kernel <<< G1, B1 >>> (*voxelNMIGradientArray_d);
    NR_CUDA_CHECK_KERNEL(G1,B1)

    NR_CUDA_SAFE_CALL(cudaUnbindTexture(firstTargetImageTexture));
    NR_CUDA_SAFE_CALL(cudaUnbindTexture(secondTargetImageTexture));
    NR_CUDA_SAFE_CALL(cudaUnbindTexture(firstResultImageTexture));
    NR_CUDA_SAFE_CALL(cudaUnbindTexture(secondResultImageTexture));
    NR_CUDA_SAFE_CALL(cudaUnbindTexture(firstResultImageGradientTexture));
    NR_CUDA_SAFE_CALL(cudaUnbindTexture(secondResultImageGradientTexture));
    NR_CUDA_SAFE_CALL(cudaUnbindTexture(histogramTexture));
    NR_CUDA_SAFE_CALL(cudaUnbindTexture(maskTexture));
}

#endif
