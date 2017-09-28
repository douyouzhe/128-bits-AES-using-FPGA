#include "xaxidma.h"
#include "xparameters.h"
#include "xdebug.h"
#include "xtft.h"
#include "xparameters.h"
#include "xuartps_hw.h"
#include <stdio.h>
#include <math.h>
#include <stdlib.h>
#include "xscutimer.h"

#define TIMER_DEVICE_ID	XPAR_SCUTIMER_DEVICE_ID
#define TIMER_LOAD_VALUE 0xFFFFFFFF


XScuTimer Timer;		/* Cortex A9 SCU Private Timer Instance */



#define TFT_DEVICE_ID    XPAR_TFT_0_DEVICE_ID
#define DDR_HIGH_ADDR    XPAR_PS7_DDR_0_S_AXI_HIGHADDR


#ifdef XPAR_V6DDR_0_S_AXI_HIGHADDR
#define DDR_HIGH_ADDR		XPAR_V6DDR_0_S_AXI_HIGHADDR
#elif XPAR_S6DDR_0_S0_AXI_HIGHADDR
#define DDR_HIGH_ADDR		XPAR_S6DDR_0_S0_AXI_HIGHADDR
#elif XPAR_AXI_7SDDR_0_S_AXI_HIGHADDR
#define DDR_HIGH_ADDR		XPAR_AXI_7SDDR_0_S_AXI_HIGHADDR
#elif XPAR_MPMC_0_MPMC_HIGHADDR
#define DDR_HIGH_ADDR		XPAR_MPMC_0_MPMC_HIGHADDR
#endif



#ifndef DDR_HIGH_ADDR
#warning "CHECK FOR THE VALID DDR ADDRESS IN XPARAMETERS.H"
#endif

#define DISPLAY_COLUMNS  640
#define DISPLAY_ROWS     480



#define DMA_DEV_ID        XPAR_AXIDMA_0_DEVICE_ID
#define DDR_BASE_ADDR        XPAR_DDR_MEM_BASEADDR

#ifndef DDR_BASE_ADDR
#warning CHECK FOR THE VALID DDR ADDRESS IN XPARAMETERS.H, \
  DEFAULT SET TO 0x01000000
#define MEM_BASE_ADDR        0x01000000
#else
#define MEM_BASE_ADDR        (DDR_BASE_ADDR + 0x1000000)
#endif

#define TX_BUFFER_BASE        (MEM_BASE_ADDR + 0x00100000)
#define RX_BUFFER_BASE        (MEM_BASE_ADDR + 0x00300000)
#define RX_BUFFER_HIGH        (MEM_BASE_ADDR + 0x004FFFFF)

#define NUMBER_OF_WORDS     7680 //30720 bytes
#define NUMBER_OF_BYTES         NUMBER_OF_WORDS * 4

#define NUMBER_OF_TRANSFERS    NUMBER_OF_WORDS / 4
#define TFT_FRAME_ADDR        0x10000000

int Tft4218Example(u32 TftDeviceId);
int XTft_DrawSolidBox(XTft *Tft, int x1, int y1, int x2, int y2, unsigned int col);


/************************** Variable Definitions ****************************/

static XTft TftInstance;

#if (!defined(DEBUG))
extern void xil_printf(const char *format, ...);
#endif

int XAxiDma_SimplePollExample(u16 DeviceId);

int Tft4218Example(u32 TftDeviceId);
int send_key(u16 DeviceId);

u32 *TxBufferPtr;
u32 *RxBufferPtr;

unsigned char image1[10240];
unsigned char image2[10240];
unsigned char image3[10240];

XAxiDma AxiDma;

int main()
{





  int Status;
  Xil_DCacheDisable();
  Status = Tft4218Example(TFT_DEVICE_ID);


  u16 colorbytes;
  u16 mask = 0x000E;
  u32 color,RGB;

   int pixel=0;
   int i,j,k,col;
   int maincnt=0;



   TxBufferPtr = (u32 *)TX_BUFFER_BASE;
   RxBufferPtr = (u32 *)RX_BUFFER_BASE;


  xil_printf("\r\n--- Entering main() --- \r\n");
  Status = send_key(DMA_DEV_ID);
  Status = XAxiDma_SimplePollExample(DMA_DEV_ID);

  if (Status != XST_SUCCESS) {

    xil_printf("XAxiDma_SimplePollExample: Failed\r\n");
    return XST_FAILURE;
  }

  xil_printf("XAxiDma_SimplePollExample: Passed\r\n");

  xil_printf("--- Exiting main() --- \r\n");


   unsigned char codedimage[16];  //nus file => one row = 128 bytes
   unsigned char ori_image[16];  //encoded image


   for(i = 0; i < 240; i++)
   {
	   for(j = 0; j < 8; j++)
	   {
		   for(k = 0; k < 16; k++)
		   {
			   if (i<80) codedimage[k] = image1[i*8*16+j*16+k];
			   else if ((i<160)&&(i>=80)) codedimage[k] = image2[(i-80)*8*16+j*16+k];
			   else codedimage[k] = image3[(i-160)*8*16+j*16+k];

		   }

		   for(k = 0; k < 8; k++)
		   {
			  colorbytes = (((u16)codedimage[2*k]<<8)) | codedimage[2*k+1]; //colorbyte = aaaa aaaa aaaa aaa0 1110 0000 0000 0000
			  for(pixel = 0; pixel < 5; pixel++)
			  {
				  color = colorbytes & (mask << (12 - pixel*3));
				  color = color >> (12 - pixel*3 + 1);
				  RGB = 0x0;

				  if(color & 0x00000004)
				    RGB = RGB | 0x00FF0000;
				  if(color & 0x00000002)
				    RGB = RGB | 0x0000FF00;
				  if(color & 0x00000001)
				    RGB = RGB | 0x000000FF;

				  col = j*40 + k*5 + pixel;
				  XTft_SetPixel(&TftInstance,col,i,RGB);
			  }
	       }
	   }
   }



           maincnt = 0;
   for(i = 0; i < 240; i++)
   {
	   for(j = 0; j < 8; j++)
	   {

			   for(k = 0; k < 16; k=k+4)
			   {
			   ori_image[k] = (u8)((RxBufferPtr[maincnt]>>24) & 0x000000FF) ;
			   ori_image[k+1] = (u8)((RxBufferPtr[maincnt]>>16) & 0x000000FF);
			   ori_image[k+2] = (u8)((RxBufferPtr[maincnt] >> 8) &0x000000FF);
			   ori_image[k+3] = (u8)((RxBufferPtr[maincnt]) & 0x000000FF);
			   maincnt++;
         	   }

			   for(k = 0; k < 8; k++)
			   {
			      colorbytes = ((u16)ori_image[2*k]<<8) | ori_image[2*k+1];

			   	  for(pixel = 0; pixel < 5; pixel++)
			   	  {
			           	color = colorbytes & (mask<<(12-pixel*3));
			           	color = color >> (12-pixel*3+1);
			           		   RGB = 0x0;

			           		   if(color & 0x00000004)
			           		  	  RGB = RGB | 0x00FF0000;
			           		   if(color & 0x00000002)
			           		  	  RGB = RGB | 0x0000FF00;
			           		   if(color & 0x00000001)
			           		  	  RGB = RGB | 0x000000FF;

			           	col = j*40 + k*5 + pixel +320;
			           	XTft_SetPixel(&TftInstance,col,i+240, RGB);
			  	   }
			   }
           }
	 }



  return XST_SUCCESS;

}


int send_key(u16 DeviceId)
{
  XAxiDma_Config *CfgPtr;
  int Status;
  u32 Index;

  unsigned char Input[16];




  CfgPtr = XAxiDma_LookupConfig(DeviceId);
  if (!CfgPtr) {
    xil_printf("No config found for %d\r\n", DeviceId);
    return XST_FAILURE;
  }
  xil_printf("Found config for AXI DMA\n\r");

  Status = XAxiDma_CfgInitialize(&AxiDma, CfgPtr);
  if (Status != XST_SUCCESS) {
    xil_printf("Initialization failed %d\r\n", Status);
    return XST_FAILURE;
  }
  xil_printf("Finish initializing configurations for AXI DMA\n\r");

  if(XAxiDma_HasSg(&AxiDma)){
    xil_printf("Device configured as SG mode \r\n");
    return XST_FAILURE;
  }
  xil_printf("AXI DMA is configured as Simple Transfer mode\n\r");


  XAxiDma_IntrDisable(&AxiDma, XAXIDMA_IRQ_ALL_MASK,
      XAXIDMA_DEVICE_TO_DMA);
  XAxiDma_IntrDisable(&AxiDma, XAXIDMA_IRQ_ALL_MASK,
      XAXIDMA_DMA_TO_DEVICE);

  for(Index=0;Index<16;Index++)
  {
	  Input[Index] = XUartPs_RecvByte(XPAR_PS7_UART_1_BASEADDR);
  }


  TxBufferPtr[0] = ((u32)Input[0]<<24) | ((u32)Input[1]<<16) | ((u32)Input[2]<<8) | Input[3];
  TxBufferPtr[1] = ((u32)Input[4]<<24) | ((u32)Input[5]<<16) | ((u32)Input[6]<<8) | Input[7];
  TxBufferPtr[2] = ((u32)Input[8]<<24) | ((u32)Input[9]<<16) | ((u32)Input[10]<<8) | Input[11];
  TxBufferPtr[3] = ((u32)Input[12]<<24) | ((u32)Input[13]<<16) | ((u32)Input[14]<<8) | Input[15];


  Xil_DCacheFlushRange((u32)TxBufferPtr, NUMBER_OF_BYTES);






    Status = XAxiDma_SimpleTransfer(&AxiDma,(u32) (TxBufferPtr),
    		4 * 4, XAXIDMA_DMA_TO_DEVICE);


    if (Status != XST_SUCCESS) {
      return XST_FAILURE;
    }






    xil_printf("Waiting for AXI DMA \n\r");

    while (XAxiDma_Busy(&AxiDma,XAXIDMA_DMA_TO_DEVICE)) {
    }
    xil_printf("DMA_TO_DEVICE finishes \n\r");
    xil_printf("DEVICE_TO_DMA finishes \n\r");



  return XST_SUCCESS;
}







int XAxiDma_SimplePollExample(u16 DeviceId)
{



	int Status;
	volatile u32 CntValue1;
	XScuTimer_Config *ConfigPtr1;
	XScuTimer *TimerInstancePtr = &Timer;


		ConfigPtr1 = XScuTimer_LookupConfig(TIMER_DEVICE_ID);

		Status = XScuTimer_CfgInitialize(TimerInstancePtr, ConfigPtr1,
					 ConfigPtr1->BaseAddr);
		if (Status != XST_SUCCESS) {
			return XST_FAILURE;
		}

  u32 Index;

  int i;


  for(i = 0; i < 10240; i++){
	  image1[i]= XUartPs_RecvByte(XPAR_PS7_UART_1_BASEADDR);

  }
  for(i = 0; i < 10240; i++){
	  image2[i]= XUartPs_RecvByte(XPAR_PS7_UART_1_BASEADDR);

  }
  for(i = 0; i < 10240; i++){
	  image3[i]= XUartPs_RecvByte(XPAR_PS7_UART_1_BASEADDR);

  }

  for(Index = 0; Index < (NUMBER_OF_WORDS/3); Index ++)
  {
   TxBufferPtr[Index] = (((u32)image1[4*Index])<<24) | (((u32)image1[4*Index + 1]) << 16) | (((u32)image1[4*Index + 2]) << 8) | image1[4*Index+3];
  }
  for(Index = 0; Index < (NUMBER_OF_WORDS/3); Index ++)
  {
   TxBufferPtr[2560+Index] = (((u32)image2[4*Index])<<24) | (((u32)image2[4*Index + 1]) << 16) | (((u32)image2[4*Index + 2]) << 8) | image2[4*Index+3];
  }
  for(Index = 0; Index < (NUMBER_OF_WORDS/3); Index ++)
  {
   TxBufferPtr[5120+Index] = (((u32)image3[4*Index])<<24) | (((u32)image3[4*Index + 1]) << 16) | (((u32)image3[4*Index + 2]) << 8) | image3[4*Index+3];
  }




  Xil_DCacheFlushRange((u32)TxBufferPtr, NUMBER_OF_BYTES);



  for(Index = 0; Index < NUMBER_OF_TRANSFERS; Index ++)
  {


	   	XScuTimer_LoadTimer(TimerInstancePtr, TIMER_LOAD_VALUE);
	   	XScuTimer_Start(TimerInstancePtr);



	  Status = XAxiDma_SimpleTransfer(&AxiDma,(u32) (RxBufferPtr + Index*4),
	        		4 * 4, XAXIDMA_DEVICE_TO_DMA);

    if (Status != XST_SUCCESS) {
	      return XST_FAILURE;
	    }



    Status = XAxiDma_SimpleTransfer(&AxiDma,(u32) (TxBufferPtr + Index*4),
    		4 * 4, XAXIDMA_DMA_TO_DEVICE);


    if (Status != XST_SUCCESS) {
      return XST_FAILURE;
    }



    CntValue1 = XScuTimer_GetCounterValue(TimerInstancePtr);
    XScuTimer_Stop(TimerInstancePtr);


      while (XAxiDma_Busy(&AxiDma,XAXIDMA_DMA_TO_DEVICE)) {

      }


      while (XAxiDma_Busy(&AxiDma,XAXIDMA_DEVICE_TO_DMA)) {

      }

  }
  xil_printf("time used for one cycle is : %d clock cycles \r\n",TIMER_LOAD_VALUE-CntValue1);
  return XST_SUCCESS;
}

int Tft4218Example(u32 TftDeviceId)
{
  int Status;
  XTft_Config *TftConfigPtr;

  TftConfigPtr = XTft_LookupConfig(TftDeviceId);
  if (TftConfigPtr == (XTft_Config *)NULL) {
    return XST_FAILURE;
  }

  Status = XTft_CfgInitialize(&TftInstance, TftConfigPtr,
      TftConfigPtr->BaseAddress);
  if (Status != XST_SUCCESS) {
    return XST_FAILURE;
  }

  while (XTft_GetVsyncStatus(&TftInstance) !=
      XTFT_IESR_VADDRLATCH_STATUS_MASK);

  XTft_SetFrameBaseAddr(&TftInstance, TFT_FRAME_ADDR);
  XTft_ClearScreen(&TftInstance);
  print("Finish initializing TFT\n\r");

  print("  TFT test completed!\r\n");
  print("  You should see vertical color and grayscale bars\r\n");
  print("  across your VGA Output Monitor\r\n\r\n");
  return 0;
}
