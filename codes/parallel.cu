#include <stdio.h>
#include <stdlib.h>

typedef short WORD;
typedef int DWORD;
typedef int LONG;

__device__ static unsigned char s_box[256] = {
	// 0     1     2     3     4     5     6     7     8     9     a     b     c     d     e     f
	0x63, 0x7c, 0x77, 0x7b, 0xf2, 0x6b, 0x6f, 0xc5, 0x30, 0x01, 0x67, 0x2b, 0xfe, 0xd7, 0xab, 0x76, // 0
	0xca, 0x82, 0xc9, 0x7d, 0xfa, 0x59, 0x47, 0xf0, 0xad, 0xd4, 0xa2, 0xaf, 0x9c, 0xa4, 0x72, 0xc0, // 1
	0xb7, 0xfd, 0x93, 0x26, 0x36, 0x3f, 0xf7, 0xcc, 0x34, 0xa5, 0xe5, 0xf1, 0x71, 0xd8, 0x31, 0x15, // 2
	0x04, 0xc7, 0x23, 0xc3, 0x18, 0x96, 0x05, 0x9a, 0x07, 0x12, 0x80, 0xe2, 0xeb, 0x27, 0xb2, 0x75, // 3
	0x09, 0x83, 0x2c, 0x1a, 0x1b, 0x6e, 0x5a, 0xa0, 0x52, 0x3b, 0xd6, 0xb3, 0x29, 0xe3, 0x2f, 0x84, // 4
	0x53, 0xd1, 0x00, 0xed, 0x20, 0xfc, 0xb1, 0x5b, 0x6a, 0xcb, 0xbe, 0x39, 0x4a, 0x4c, 0x58, 0xcf, // 5
	0xd0, 0xef, 0xaa, 0xfb, 0x43, 0x4d, 0x33, 0x85, 0x45, 0xf9, 0x02, 0x7f, 0x50, 0x3c, 0x9f, 0xa8, // 6
	0x51, 0xa3, 0x40, 0x8f, 0x92, 0x9d, 0x38, 0xf5, 0xbc, 0xb6, 0xda, 0x21, 0x10, 0xff, 0xf3, 0xd2, // 7
	0xcd, 0x0c, 0x13, 0xec, 0x5f, 0x97, 0x44, 0x17, 0xc4, 0xa7, 0x7e, 0x3d, 0x64, 0x5d, 0x19, 0x73, // 8
	0x60, 0x81, 0x4f, 0xdc, 0x22, 0x2a, 0x90, 0x88, 0x46, 0xee, 0xb8, 0x14, 0xde, 0x5e, 0x0b, 0xdb, // 9
	0xe0, 0x32, 0x3a, 0x0a, 0x49, 0x06, 0x24, 0x5c, 0xc2, 0xd3, 0xac, 0x62, 0x91, 0x95, 0xe4, 0x79, // a
	0xe7, 0xc8, 0x37, 0x6d, 0x8d, 0xd5, 0x4e, 0xa9, 0x6c, 0x56, 0xf4, 0xea, 0x65, 0x7a, 0xae, 0x08, // b
	0xba, 0x78, 0x25, 0x2e, 0x1c, 0xa6, 0xb4, 0xc6, 0xe8, 0xdd, 0x74, 0x1f, 0x4b, 0xbd, 0x8b, 0x8a, // c
	0x70, 0x3e, 0xb5, 0x66, 0x48, 0x03, 0xf6, 0x0e, 0x61, 0x35, 0x57, 0xb9, 0x86, 0xc1, 0x1d, 0x9e, // d
	0xe1, 0xf8, 0x98, 0x11, 0x69, 0xd9, 0x8e, 0x94, 0x9b, 0x1e, 0x87, 0xe9, 0xce, 0x55, 0x28, 0xdf, // e
	0x8c, 0xa1, 0x89, 0x0d, 0xbf, 0xe6, 0x42, 0x68, 0x41, 0x99, 0x2d, 0x0f, 0xb0, 0x54, 0xbb, 0x16};// f

__device__ static unsigned char inv_s_box[256] = {
	// 0     1     2     3     4     5     6     7     8     9     a     b     c     d     e     f
	0x52, 0x09, 0x6a, 0xd5, 0x30, 0x36, 0xa5, 0x38, 0xbf, 0x40, 0xa3, 0x9e, 0x81, 0xf3, 0xd7, 0xfb, // 0
	0x7c, 0xe3, 0x39, 0x82, 0x9b, 0x2f, 0xff, 0x87, 0x34, 0x8e, 0x43, 0x44, 0xc4, 0xde, 0xe9, 0xcb, // 1
	0x54, 0x7b, 0x94, 0x32, 0xa6, 0xc2, 0x23, 0x3d, 0xee, 0x4c, 0x95, 0x0b, 0x42, 0xfa, 0xc3, 0x4e, // 2
	0x08, 0x2e, 0xa1, 0x66, 0x28, 0xd9, 0x24, 0xb2, 0x76, 0x5b, 0xa2, 0x49, 0x6d, 0x8b, 0xd1, 0x25, // 3
	0x72, 0xf8, 0xf6, 0x64, 0x86, 0x68, 0x98, 0x16, 0xd4, 0xa4, 0x5c, 0xcc, 0x5d, 0x65, 0xb6, 0x92, // 4
	0x6c, 0x70, 0x48, 0x50, 0xfd, 0xed, 0xb9, 0xda, 0x5e, 0x15, 0x46, 0x57, 0xa7, 0x8d, 0x9d, 0x84, // 5
	0x90, 0xd8, 0xab, 0x00, 0x8c, 0xbc, 0xd3, 0x0a, 0xf7, 0xe4, 0x58, 0x05, 0xb8, 0xb3, 0x45, 0x06, // 6
	0xd0, 0x2c, 0x1e, 0x8f, 0xca, 0x3f, 0x0f, 0x02, 0xc1, 0xaf, 0xbd, 0x03, 0x01, 0x13, 0x8a, 0x6b, // 7
	0x3a, 0x91, 0x11, 0x41, 0x4f, 0x67, 0xdc, 0xea, 0x97, 0xf2, 0xcf, 0xce, 0xf0, 0xb4, 0xe6, 0x73, // 8
	0x96, 0xac, 0x74, 0x22, 0xe7, 0xad, 0x35, 0x85, 0xe2, 0xf9, 0x37, 0xe8, 0x1c, 0x75, 0xdf, 0x6e, // 9
	0x47, 0xf1, 0x1a, 0x71, 0x1d, 0x29, 0xc5, 0x89, 0x6f, 0xb7, 0x62, 0x0e, 0xaa, 0x18, 0xbe, 0x1b, // a
	0xfc, 0x56, 0x3e, 0x4b, 0xc6, 0xd2, 0x79, 0x20, 0x9a, 0xdb, 0xc0, 0xfe, 0x78, 0xcd, 0x5a, 0xf4, // b
	0x1f, 0xdd, 0xa8, 0x33, 0x88, 0x07, 0xc7, 0x31, 0xb1, 0x12, 0x10, 0x59, 0x27, 0x80, 0xec, 0x5f, // c
	0x60, 0x51, 0x7f, 0xa9, 0x19, 0xb5, 0x4a, 0x0d, 0x2d, 0xe5, 0x7a, 0x9f, 0x93, 0xc9, 0x9c, 0xef, // d
	0xa0, 0xe0, 0x3b, 0x4d, 0xae, 0x2a, 0xf5, 0xb0, 0xc8, 0xeb, 0xbb, 0x3c, 0x83, 0x53, 0x99, 0x61, // e
	0x17, 0x2b, 0x04, 0x7e, 0xba, 0x77, 0xd6, 0x26, 0xe1, 0x69, 0x14, 0x63, 0x55, 0x21, 0x0c, 0x7d};// f

__device__ int Nb = 4;

__device__ void shift_rows(unsigned char *state) {
	unsigned char i, k, s, tmp;
	for (i = 1; i < 4; i++) {
		s = 0;
		while (s < i) {
			tmp = state[Nb*i+0];
			
			for (k = 1; k < Nb; k++) {
				state[Nb*i+k-1] = state[Nb*i+k];
			}

			state[Nb*i+Nb-1] = tmp;
			s++;
		}
	}
}

__device__ void inv_shift_rows(unsigned char *state) {
	unsigned char i, k, s, tmp;
	for (i = 1; i < 4; i++) {
		s = 0;
		while (s < i) {
			tmp = state[Nb*i+Nb-1];
			
			for (k = Nb-1; k > 0; k--) {
				state[Nb*i+k] = state[Nb*i+k-1];
			}

			state[Nb*i+0] = tmp;
			s++;
		}
	}
}

__device__ unsigned char gmult(unsigned char a, unsigned char b) {

	unsigned char p = 0, i = 0, hbs = 0;

	for (i = 0; i < 8; i++) {
		if (b & 1) {
			p ^= a;
		}

		hbs = a & 0x80;
		a <<= 1;
		if (hbs) a ^= 0x1b; // 0000 0001 0001 1011	
		b >>= 1;
	}

	return (unsigned char)p;
}

__device__ void coef_mult(unsigned char *a, unsigned char *b, unsigned char *d) {

	d[0] = gmult(a[0],b[0])^gmult(a[3],b[1])^gmult(a[2],b[2])^gmult(a[1],b[3]);
	d[1] = gmult(a[1],b[0])^gmult(a[0],b[1])^gmult(a[3],b[2])^gmult(a[2],b[3]);
	d[2] = gmult(a[2],b[0])^gmult(a[1],b[1])^gmult(a[0],b[2])^gmult(a[3],b[3]);
	d[3] = gmult(a[3],b[0])^gmult(a[2],b[1])^gmult(a[1],b[2])^gmult(a[0],b[3]);
}

__device__ void mix_columns(unsigned char *state) {

	unsigned char a[] = {0x02, 0x01, 0x01, 0x03}; // a(x) = {02} + {01}x + {01}x2 + {03}x3
	unsigned char i, j, col[4], res[4];

	for (j = 0; j < Nb; j++) {
		for (i = 0; i < 4; i++) {
			col[i] = state[Nb*i+j];
		}

		coef_mult(a, col, res);

		for (i = 0; i < 4; i++) {
			state[Nb*i+j] = res[i];
		}
	}
}


__device__ void inv_mix_columns(unsigned char *state) {

	unsigned char a[] = {0x0e, 0x09, 0x0d, 0x0b}; // a(x) = {0e} + {09}x + {0d}x2 + {0b}x3
	unsigned char i, j, col[4], res[4];

	for (j = 0; j < Nb; j++) {
		for (i = 0; i < 4; i++) {
			col[i] = state[Nb*i+j];
		}

		coef_mult(a, col, res);

		for (i = 0; i < 4; i++) {
			state[Nb*i+j] = res[i];
		}
	}
}

//Round Keys
__device__ unsigned char key[16] = {
	0x00, 0x01, 0x02, 0x03,
	0x04, 0x05, 0x06, 0x07,
	0x08, 0x09, 0x0a, 0x0b,
	0x0c, 0x0d, 0x0e, 0x0f};

__device__ void key_xor(unsigned char *state){
	for(int i=0;i < 16;i++)
	{
	   state[i] = state[i]^key[i];
	}
}



#pragma pack(push, 1)
typedef struct tagBITMAPFILEHEADER
{
    WORD bfType;  //specifies the file type
    DWORD bfSize;  //specifies the size in bytes of the bitmap file
    WORD bfReserved1;  //reserved; must be 0
    WORD bfReserved2;  //reserved; must be 0
    DWORD bOffBits;  //species the offset in bytes from the bitmapfileheader to the bitmap bits
}BITMAPFILEHEADER;
#pragma pack(pop)


#pragma pack(push, 1)
typedef struct tagBITMAPINFOHEADER
{
    DWORD biSize;  //specifies the number of bytes required by the struct
    LONG biWidth;  //specifies width in pixels
    LONG biHeight;  //species height in pixels
    WORD biPlanes; //specifies the number of color planes, must be 1
    WORD biBitCount; //specifies the number of bit per pixel
    DWORD biCompression;//spcifies the type of compression
    DWORD biSizeImage;  //size of image in bytes
    LONG biXPelsPerMeter;  //number of pixels per meter in x axis
    LONG biYPelsPerMeter;  //number of pixels per meter in y axis
    DWORD biClrUsed;  //number of colors used by th ebitmap
    DWORD biClrImportant;  //number of colors that are important
}BITMAPINFOHEADER;
#pragma pack(pop)


__global__ void RB_Swap(unsigned char *imageData, int size)
{
    int imageIdx = threadIdx.x+blockIdx.x*blockDim.x;

    if(imageIdx<size/3)
    {
        unsigned char tempRGB;
        imageIdx = imageIdx*3;
        tempRGB = imageData[imageIdx];
        imageData[imageIdx] = imageData[imageIdx + 2];
        imageData[imageIdx + 2] = tempRGB;
    }
}



unsigned char *LoadBitmapFile(char *filename, BITMAPINFOHEADER *bitmapInfoHeader, BITMAPFILEHEADER *bitmapFileHeader)
{
    FILE *filePtr; //our file pointer
    unsigned char *bitmapImage;  //store image data

    //open filename in read binary mode
    filePtr = fopen(filename,"rb");
    if (filePtr == NULL)
        return NULL;

    //read the bitmap file header
    fread(bitmapFileHeader, sizeof(BITMAPFILEHEADER),1,filePtr);

    
    //verify that this is a bmp file by check bitmap id
    if (bitmapFileHeader->bfType !=0x4D42)
    {
        fclose(filePtr);
        return NULL;
    }
    
    //read the bitmap info header
    fread(bitmapInfoHeader, sizeof(BITMAPINFOHEADER),1,filePtr); // small edit. forgot to add the closing bracket at sizeof

    //move file point to the begging of bitmap data
    fseek(filePtr, bitmapFileHeader->bOffBits, SEEK_SET);

    //allocate enough memory for the bitmap image data
    bitmapImage = (unsigned char*)malloc(bitmapInfoHeader->biSizeImage);

    //verify memory allocation
    if (!bitmapImage)
    {
        free(bitmapImage);
        fclose(filePtr);
        return NULL;
    }

    //read in the bitmap image data
    fread(bitmapImage,1,bitmapInfoHeader->biSizeImage,filePtr);

    //make sure bitmap image data was read
    if (bitmapImage == NULL)
    {
        fclose(filePtr);
        return NULL;
    }

    cudaEvent_t start;
    cudaEventCreate(&start);
    cudaEvent_t end;
    cudaEventCreate(&end);
    float swapTime;

    //swap the r and b values to get RGB (bitmap is BGR)    
    unsigned char *d_bitmapImage;  //store image data in device
    
    //Allocate size to array in device memory
    cudaMalloc((void**)&d_bitmapImage, bitmapInfoHeader->biSizeImage);

    //Copy data from host to device
    cudaMemcpy(d_bitmapImage, bitmapImage, bitmapInfoHeader->biSizeImage, cudaMemcpyHostToDevice);

    int B = ceil(bitmapInfoHeader->biSizeImage/(1024*16));
    int T = 1024;

    //Kernel call
    cudaEventRecord(start, 0);
    //RB_Swap<<<B, T>>> (d_bitmapImage, bitmapInfoHeader->biSizeImage);
    cudaEventRecord(end, 0);
    cudaEventSynchronize(end);

    cudaMemcpy(bitmapImage, d_bitmapImage, bitmapInfoHeader->biSizeImage, cudaMemcpyDeviceToHost);

    cudaEventElapsedTime(&swapTime, start, end);
    printf("Load Swap Time: %fms\n",swapTime);

    cudaEventDestroy(start);
    cudaEventDestroy(end);

    //close file and return bitmap iamge data
    fclose(filePtr);
    return bitmapImage;
}

void ReloadBitmapFile(char *filename, unsigned char *bitmapImage, BITMAPFILEHEADER *bitmapFileHeader, BITMAPINFOHEADER *bitmapInfoHeader)
{
    FILE *filePtr; //our file pointer

    //open filename in write binary mode
    filePtr = fopen(filename,"wb");
    if (filePtr == NULL)
    {
        printf("\nERROR: Cannot open file %s", filename);
        exit(1);
    }
        

    //write the bitmap file header
    fwrite(bitmapFileHeader, sizeof(BITMAPFILEHEADER),1,filePtr);

    //write the bitmap info header
    fwrite(bitmapInfoHeader, sizeof(BITMAPINFOHEADER),1,filePtr); // small edit. forgot to add the closing bracket at sizeof

    //swap the r and b values to get RGB (bitmap is BGR)

    unsigned char *d_bitmapImage;  //store image data in device
    
    //Allocate size to array in device memory
    cudaMalloc((void**)&d_bitmapImage, bitmapInfoHeader->biSizeImage);

    //Copy data from host to device
    cudaMemcpy(d_bitmapImage, bitmapImage, bitmapInfoHeader->biSizeImage, cudaMemcpyHostToDevice);

    int B = ceil(bitmapInfoHeader->biSizeImage/(1024*16));
    int T = 1024;

    //Kernel call
    
    //RB_Swap<<<B, T>>> (d_bitmapImage, bitmapInfoHeader->biSizeImage);

    cudaMemcpy(bitmapImage, d_bitmapImage, bitmapInfoHeader->biSizeImage, cudaMemcpyDeviceToHost);

    //write in the bitmap image data
    fwrite(bitmapImage,bitmapInfoHeader->biSizeImage,1,filePtr);

    //close file
    fclose(filePtr);
}

__global__ void encrypt(unsigned char *bitmapImage, int size, int threadN)
{
    int threadId = threadIdx.x + blockIdx.x*blockDim.x;
    __shared__ unsigned char sdata[512*16];
    int i;
    unsigned int tid = threadIdx.x;

    for(int k = tid * 16; k < (tid + 1) * 16; k++){
	int gid = k + blockIdx.x * 512 * 16;
        if(gid < size)
	   sdata[k] = bitmapImage[gid];
    }
    __syncthreads();

   
    //substitution

    //unsigned char *p = bitmapImage;
    for(i = tid * 16; i < (tid+1) * 16; i++){
	sdata[i] = s_box[sdata[i]];
    }
    __syncthreads();

    //shift rows
    shift_rows(&sdata[tid * 16]);
    __syncthreads();

    //mix columns
    mix_columns(&sdata[tid * 16]);
    __syncthreads();

    //key_xor
    key_xor(&sdata[tid * 16]);
    __syncthreads();

    for(int k = tid * 16; k < (tid + 1) * 16; k++){
	int gid = k + blockIdx.x * 512 * 16;
        if(gid < size)
	   bitmapImage[gid] = sdata[k];
    }
    __syncthreads();

}

__global__ void decrypt(unsigned char *bitmapImage, int size, int threadN)
{
    int threadId = threadIdx.x + blockIdx.x*blockDim.x;
    __shared__ unsigned char sdata[512*16];
    int i;
    //unsigned char *p = bitmapImage;
    unsigned int tid = threadIdx.x;

    for(int k = tid * 16; k < (tid + 1) * 16; k++){
	int gid = k + blockIdx.x * 512 * 16;
        if(gid < size)
	   sdata[k] = bitmapImage[gid];
    }
    __syncthreads();

    //key_xor
    key_xor(&sdata[tid * 16]);
    __syncthreads();

    //mix columns
    inv_mix_columns(&sdata[tid * 16]);
    __syncthreads();

    //substitution
    for(i = tid * 16; i < (tid+1) * 16; i++){
	sdata[i] = inv_s_box[sdata[i]];
    }
    __syncthreads();

    if(threadId * 16 < size)
	inv_shift_rows(&sdata[tid * 16]);
    __syncthreads();

    for(int k = tid * 16; k < (tid + 1) * 16; k++){
	int gid = k + blockIdx.x * 512 * 16;
        if(gid < size)
	   bitmapImage[gid] = sdata[k];
    }
    __syncthreads();

}

int main()
{
    BITMAPINFOHEADER bitmapInfoHeader;
    BITMAPFILEHEADER bitmapFileHeader;
    unsigned char *bitmapData;
    bitmapData = LoadBitmapFile("lena.bmp",&bitmapInfoHeader, &bitmapFileHeader);
    printf("%d\n",bitmapInfoHeader.biSizeImage);
    
    /*
    //Print array to file
    FILE *fout = fopen("out.bmp","wb");
    fwrite(bitmapData,bitmapInfoHeader.biSizeImage,1,fout);
    */

    cudaEvent_t start;
    cudaEventCreate(&start);
    cudaEvent_t end;
    cudaEventCreate(&end);
    float encryptionTime, decryptionTime, HostToDevice, DeviceToHost;
    
    //Encryption

    int key = 8000;

    unsigned char *d_bitmapImage;  //store image data in device
    
    //Allocate size to array in device memory
    cudaMalloc((void**)&d_bitmapImage, bitmapInfoHeader.biSizeImage);

    //Copy data from host to device
    cudaEventRecord(start, 0);
    cudaMemcpy(d_bitmapImage, bitmapData, bitmapInfoHeader.biSizeImage, cudaMemcpyHostToDevice);
    cudaEventRecord(end, 0);
    cudaEventSynchronize(end);
    cudaEventElapsedTime(&HostToDevice, start, end);
    printf("Host to Device Time: %fms\n",HostToDevice);

    int B = ceil(bitmapInfoHeader.biSizeImage/(512*16));
    int T = 512;
    int threadN = B * T;

    //Kernel call
    cudaEventRecord(start, 0);
    encrypt<<<B, T>>> (d_bitmapImage, bitmapInfoHeader.biSizeImage, threadN);
    cudaEventRecord(end, 0);
    cudaEventSynchronize(end);
    cudaEventElapsedTime(&encryptionTime, start, end);
    printf("Encryption Time: %fms\n",encryptionTime);

    //Copy data from device to host
    cudaEventRecord(start, 0);
    cudaMemcpy(bitmapData, d_bitmapImage, bitmapInfoHeader.biSizeImage, cudaMemcpyDeviceToHost);
    cudaEventRecord(end, 0);
    cudaEventSynchronize(end);
    cudaEventElapsedTime(&DeviceToHost, start, end);
    printf("Device to Host Time: %fms\n",DeviceToHost);
    
    ReloadBitmapFile("Encrypted.bmp", bitmapData, &bitmapFileHeader, &bitmapInfoHeader);

    //load encrypted image to array
    bitmapData = LoadBitmapFile("Encrypted.bmp",&bitmapInfoHeader, &bitmapFileHeader);

    //Decryption
    cudaMemcpy(d_bitmapImage, bitmapData, bitmapInfoHeader.biSizeImage, cudaMemcpyHostToDevice);
    cudaEventRecord(start, 0);
    decrypt<<<B, T>>> (d_bitmapImage, bitmapInfoHeader.biSizeImage, threadN);
    cudaEventRecord(end, 0);
    cudaEventSynchronize(end);
    cudaEventElapsedTime(&decryptionTime, start, end);
    printf("Decryption Time: %fms\n",decryptionTime);
    cudaMemcpy(bitmapData, d_bitmapImage, bitmapInfoHeader.biSizeImage, cudaMemcpyDeviceToHost);

    //decrypt(bitmapData, bitmapInfoHeader.biSizeImage);

    ReloadBitmapFile("Decrypted.bmp", bitmapData, &bitmapFileHeader, &bitmapInfoHeader);

    cudaEventDestroy(start);
    cudaEventDestroy(end);

    cudaFree(d_bitmapImage);

    return 0;
}
