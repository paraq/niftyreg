/*
 *  _reg_resampling_gpu.cu
 *
 *
 *  Created by Marc Modat on 24/03/2009.
 *  Copyright (c) 2009, University College London. All rights reserved.
 *  Centre for Medical Image Computing (CMIC)
 *  See the LICENSE.txt file in the nifty_reg root folder
 *
 */

#ifndef _REG_RESAMPLING_GPU_CU
#define _REG_RESAMPLING_GPU_CU

#include "_reg_resampling_gpu.h"
#include "_reg_resampling_kernels.cu"

#include <curand.h>
#include <curand_kernel.h>

#include <unistd.h>
#include <sys/time.h>

/* *************************************************************** */
/* *************************************************************** */
void reg_resampleSourceImage_gpu(nifti_image *sourceImage,
                                float **resultImageArray_d,
                                cudaArray **sourceImageArray_d,
                                float4 **positionFieldImageArray_d,
                                int **mask_d,
                                int activeVoxelNumber,
                                float sourceBGValue)
{
    int3 sourceDim = make_int3(sourceImage->nx, sourceImage->ny, sourceImage->nz);

    NR_CUDA_SAFE_CALL(cudaMemcpyToSymbol(c_SourceDim,&sourceDim,sizeof(int3)))
    NR_CUDA_SAFE_CALL(cudaMemcpyToSymbol(c_PaddingValue,&sourceBGValue,sizeof(float)))
    NR_CUDA_SAFE_CALL(cudaMemcpyToSymbol(c_ActiveVoxelNumber,&activeVoxelNumber,sizeof(int)))
	struct timeval t1, t2;
    double elapsedTime;
	
    //Bind source image array to a 3D texture
    sourceTexture.normalized = true;
    sourceTexture.filterMode = cudaFilterModeLinear;
    sourceTexture.addressMode[0] = cudaAddressModeWrap;
    sourceTexture.addressMode[1] = cudaAddressModeWrap;
    sourceTexture.addressMode[2] = cudaAddressModeWrap;

    cudaChannelFormatDesc channelDesc = cudaCreateChannelDesc<float>();
    NR_CUDA_SAFE_CALL(cudaBindTextureToArray(sourceTexture, *sourceImageArray_d, channelDesc))

    //Bind positionField to texture
    NR_CUDA_SAFE_CALL(cudaBindTexture(0, positionFieldTexture, *positionFieldImageArray_d, activeVoxelNumber*sizeof(float4)))

    //Bind positionField to texture
    NR_CUDA_SAFE_CALL(cudaBindTexture(0, maskTexture, *mask_d, activeVoxelNumber*sizeof(int)))

    // Bind the real to voxel matrix to texture
    mat44 *sourceMatrix;
    if(sourceImage->sform_code>0)
        sourceMatrix=&(sourceImage->sto_ijk);
    else sourceMatrix=&(sourceImage->qto_ijk);
    float4 *sourceRealToVoxel_h;NR_CUDA_SAFE_CALL(cudaMallocHost(&sourceRealToVoxel_h, 3*sizeof(float4)))
    float4 *sourceRealToVoxel_d;
    NR_CUDA_SAFE_CALL(cudaMalloc(&sourceRealToVoxel_d, 3*sizeof(float4)))
    for(int i=0; i<3; i++){
        sourceRealToVoxel_h[i].x=sourceMatrix->m[i][0];
        sourceRealToVoxel_h[i].y=sourceMatrix->m[i][1];
        sourceRealToVoxel_h[i].z=sourceMatrix->m[i][2];
        sourceRealToVoxel_h[i].w=sourceMatrix->m[i][3];
    }
	gettimeofday(&t1, NULL);
    NR_CUDA_SAFE_CALL(cudaMemcpy(sourceRealToVoxel_d, sourceRealToVoxel_h, 3*sizeof(float4), cudaMemcpyHostToDevice))
    NR_CUDA_SAFE_CALL(cudaFreeHost((void *)sourceRealToVoxel_h))
    NR_CUDA_SAFE_CALL(cudaBindTexture(0, sourceMatrixTexture, sourceRealToVoxel_d, 3*sizeof(float4)))

    const unsigned int Grid_reg_resampleSourceImage = (unsigned int)ceil(sqrtf((float)activeVoxelNumber/(float)Block_reg_resampleSourceImage));
    dim3 B1(Block_reg_resampleSourceImage,1,1);
    dim3 G1(Grid_reg_resampleSourceImage,Grid_reg_resampleSourceImage,1);
    reg_resampleSourceImage_kernel <<< G1, B1 >>> (*resultImageArray_d);
    NR_CUDA_CHECK_KERNEL(G1,B1)

    NR_CUDA_SAFE_CALL(cudaUnbindTexture(sourceTexture))
    NR_CUDA_SAFE_CALL(cudaUnbindTexture(positionFieldTexture))
    NR_CUDA_SAFE_CALL(cudaUnbindTexture(maskTexture))
    NR_CUDA_SAFE_CALL(cudaUnbindTexture(sourceMatrixTexture))

    cudaFree(sourceRealToVoxel_d);
	gettimeofday(&t2, NULL);
	elapsedTime = (t2.tv_sec - t1.tv_sec) * 1000.0;      // sec to ms
    elapsedTime += (t2.tv_usec - t1.tv_usec) / 1000.0;
	printf("[NiftyReg F3D] reg_resampleSourceImage_kernel time =%f msec\n", elapsedTime);
	printf("[NiftyReg F3D] reg_resampleSourceImage_kernel throughput =%f voxel per sec\n", (activeVoxelNumber*1000)/elapsedTime);
}
/* *************************************************************** */
/* *************************************************************** */
void reg_getSourceImageGradient_gpu(nifti_image *sourceImage,
                                    cudaArray **sourceImageArray_d,
                                    float4 **positionFieldImageArray_d,
                                    float4 **resultGradientArray_d,
                                    int activeVoxelNumber,
									int *mask_d)
{
    int3 sourceDim = make_int3(sourceImage->nx, sourceImage->ny, sourceImage->nz);
	//printf("activeVoxelNumber=%d\n",activeVoxelNumber);

    NR_CUDA_SAFE_CALL(cudaMemcpyToSymbol(c_SourceDim, &sourceDim, sizeof(int3)))
    NR_CUDA_SAFE_CALL(cudaMemcpyToSymbol(c_ActiveVoxelNumber, &activeVoxelNumber, sizeof(int)))

    //Bind source image array to a 3D texture
    sourceTexture.normalized = true;
    sourceTexture.filterMode = cudaFilterModeLinear;
    sourceTexture.addressMode[0] = cudaAddressModeWrap;
    sourceTexture.addressMode[1] = cudaAddressModeWrap;
    sourceTexture.addressMode[2] = cudaAddressModeWrap;

    cudaChannelFormatDesc channelDesc = cudaCreateChannelDesc<float>();
    NR_CUDA_SAFE_CALL(cudaBindTextureToArray(sourceTexture, *sourceImageArray_d, channelDesc))
	NR_CUDA_SAFE_CALL(cudaBindTexture(0, maskTexture, mask_d, activeVoxelNumber*sizeof(int)))

    //Bind positionField to texture
    NR_CUDA_SAFE_CALL(cudaBindTexture(0, positionFieldTexture, *positionFieldImageArray_d, activeVoxelNumber*sizeof(float4)))

    // Bind the real to voxel matrix to texture
    mat44 *sourceMatrix;
    if(sourceImage->sform_code>0)
        sourceMatrix=&(sourceImage->sto_ijk);
    else sourceMatrix=&(sourceImage->qto_ijk);
    float4 *sourceRealToVoxel_h;NR_CUDA_SAFE_CALL(cudaMallocHost(&sourceRealToVoxel_h, 3*sizeof(float4)))
    float4 *sourceRealToVoxel_d;
    NR_CUDA_SAFE_CALL(cudaMalloc(&sourceRealToVoxel_d, 3*sizeof(float4)))
    for(int i=0; i<3; i++){
        sourceRealToVoxel_h[i].x=sourceMatrix->m[i][0];
        sourceRealToVoxel_h[i].y=sourceMatrix->m[i][1];
        sourceRealToVoxel_h[i].z=sourceMatrix->m[i][2];
        sourceRealToVoxel_h[i].w=sourceMatrix->m[i][3];
    }
    NR_CUDA_SAFE_CALL(cudaMemcpy(sourceRealToVoxel_d, sourceRealToVoxel_h, 3*sizeof(float4), cudaMemcpyHostToDevice))
    NR_CUDA_SAFE_CALL(cudaFreeHost((void *)sourceRealToVoxel_h))
    NR_CUDA_SAFE_CALL(cudaBindTexture(0, sourceMatrixTexture, sourceRealToVoxel_d, 3*sizeof(float4)))

    const unsigned int Grid_reg_getSourceImageGradient = (unsigned int)ceil(sqrtf((float)activeVoxelNumber/(float)Block_reg_getSourceImageGradient));
    dim3 B1(Block_reg_getSourceImageGradient,1,1);
    dim3 G1(Grid_reg_getSourceImageGradient,Grid_reg_getSourceImageGradient,1);
    reg_getSourceImageGradient_kernel <<< G1, B1 >>> (*resultGradientArray_d);
    NR_CUDA_CHECK_KERNEL(G1,B1)
    NR_CUDA_SAFE_CALL(cudaUnbindTexture(sourceTexture))
    NR_CUDA_SAFE_CALL(cudaUnbindTexture(positionFieldTexture))
    NR_CUDA_SAFE_CALL(cudaUnbindTexture(sourceMatrixTexture))
	NR_CUDA_SAFE_CALL(cudaUnbindTexture(maskTexture))

    cudaFree(sourceRealToVoxel_d);
}
/* *************************************************************** */
/* *************************************************************** */
void reg_randomsamplingMask_gpu(int *mask_d,
							int samples,
							int activeVoxelNumber)
{	dim3 B1(1024,1,1);
    dim3 G1(samples/1024,1,1);
	
	  curandState_t* states;

  /* allocate space on the GPU for the random states */
	NR_CUDA_SAFE_CALL(cudaMalloc((void**) &states, samples * sizeof(curandState_t)))
  
	//init<<<G1, B1 >>>(time(0), states);
	
	
	NR_CUDA_SAFE_CALL(cudaMalloc(&mask_d,samples*sizeof(int)))
	reg_randomsamplingMask_kernel <<< G1, B1 >>> (states,mask_d,samples,activeVoxelNumber,time(0));
	NR_CUDA_CHECK_KERNEL(G1,B1)
	
	//random sampling checking
/* 	int *targetMask_h; 
	targetMask_h=(int *)malloc(samples * sizeof(int));
	NR_CUDA_SAFE_CALL(cudaMemcpy(targetMask_h,mask_d,samples*sizeof(int),cudaMemcpyDeviceToHost))
	for (int i=0;i<samples;i++)
	{
		printf("targetMask_h[%d]=%d\n",i,targetMask_h[i]);
	}
	free(targetMask_h); */
	
}

#endif
