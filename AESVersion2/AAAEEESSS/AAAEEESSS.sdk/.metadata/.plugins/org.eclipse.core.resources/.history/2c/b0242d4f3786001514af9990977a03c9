/******************************************************************************
 *
 * (c) Copyright 2010-2013 Xilinx, Inc. All rights reserved.
 *
 * This file contains confidential and proprietary information of Xilinx, Inc.
 * and is protected under U.S. and international copyright and other
 * intellectual property laws.
 *
 * DISCLAIMER
 * This disclaimer is not a license and does not grant any rights to the
 * materials distributed herewith. Except as otherwise provided in a valid
 * license issued to you by Xilinx, and to the maximum extent permitted by
 * applicable law: (1) THESE MATERIALS ARE MADE AVAILABLE "AS IS" AND WITH ALL
 * FAULTS, AND XILINX HEREBY DISCLAIMS ALL WARRANTIES AND CONDITIONS, EXPRESS,
 * IMPLIED, OR STATUTORY, INCLUDING BUT NOT LIMITED TO WARRANTIES OF
 * MERCHANTABILITY, NON-INFRINGEMENT, OR FITNESS FOR ANY PARTICULAR PURPOSE;
 * and (2) Xilinx shall not be liable (whether in contract or tort, including
 * negligence, or under any other theory of liability) for any loss or damage
 * of any kind or nature related to, arising under or in connection with these
 * materials, including for any direct, or any indirect, special, incidental,
 * or consequential loss or damage (including loss of data, profits, goodwill,
 * or any type of loss or damage suffered as a result of any action brought by
 * a third party) even if such damage or loss was reasonably foreseeable or
 * Xilinx had been advised of the possibility of the same.
 *
 * CRITICAL APPLICATIONS
 * Xilinx products are not designed or intended to be fail-safe, or for use in
 * any application requiring fail-safe performance, such as life-support or
 * safety devices or systems, Class III medical devices, nuclear facilities,
 * applications related to the deployment of airbags, or any other applications
 * that could lead to death, personal injury, or severe property or
 * environmental damage (individually and collectively, "Critical
 * Applications"). Customer assumes the sole risk and liability of any use of
 * Xilinx products in Critical Applications, subject only to applicable laws
 * and regulations governing limitations on product liability.
 *
 * THIS COPYRIGHT NOTICE AND DISCLAIMER MUST BE RETAINED AS PART OF THIS FILE
 * AT ALL TIMES.
 *
 ******************************************************************************/
/*****************************************************************************/
/**
 *
 * @file xaxidma_example_simple_poll.c
 *
 * This file demonstrates how to use the xaxidma driver on the Xilinx AXI
 * DMA core (AXIDMA) to transfer packets in polling mode when the AXI DMA core
 * is configured in simple mode.
 *
 * This code assumes a loopback hardware widget is connected to the AXI DMA
 * core for data packet loopback.
 *
 * To see the debug print, you need a Uart16550 or uartlite in your system,
 * and please set "-DDEBUG" in your compiler options. You need to rebuild your
 * software executable.
 *
 * Make sure that MEMORY_BASE is defined properly as per the HW system. The
 * h/w system built in Area mode has a maximum DDR memory limit of 64MB. In
 * throughput mode, it is 512MB.  These limits are need to ensured for
 * proper operation of this code.
 *
 *
 * <pre>
 * MODIFICATION HISTORY:
 *
 * Ver   Who  Date     Changes
 * ----- ---- -------- -------------------------------------------------------
 * 4.00a rkv  02/22/11 New example created for simple DMA, this example is for
 *                  simple DMA
 * 5.00a srt  03/06/12 Added Flushing and Invalidation of Caches to fix CRs
 *               648103, 648701.
 *               Added V7 DDR Base Address to fix CR 649405.
 * 6.00a srt  03/27/12 Changed API calls to support MCDMA driver.
 * 7.00a srt  06/18/12 API calls are reverted back for backward compatibility.
 * 7.01a srt  11/02/12 Buffer sizes (Tx and Rx) are modified to meet maximum
 *               DDR memory limit of the h/w system built with Area mode
 * 7.02a srt  03/01/13 Updated DDR base address for IPI designs (CR 703656).
 *
 * </pre>
 *
 * ***************************************************************************

 */
/***************************** Include Files *********************************/
#include "xaxidma.h"
#include "xparameters.h"
#include "xdebug.h"



/******************** Constant Definitions **********************************/

/*
 * Device hardware build related constants.
 */

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

#define NUMBER_OF_WORDS     32
#define NUMBER_OF_BYTES         NUMBER_OF_WORDS * 4

#define TEST_START_VALUE    10

#define NUMBER_OF_TRANSFERS    NUMBER_OF_WORDS / 4

/**************************** Type Definitions *******************************/


/***************** Macros (Inline Functions) Definitions *********************/


/************************** Function Prototypes ******************************/

#if (!defined(DEBUG))
extern void xil_printf(const char *format, ...);
#endif

int XAxiDma_SimplePollExample(u16 DeviceId);
static int CheckData(u32 cur_indx);

/************************** Variable Definitions *****************************/
/*
 * Device instance definitions
 */
XAxiDma AxiDma;


/*****************************************************************************/
/*
 * The entry point for this example. It invokes the example function,
 * and reports the execution status.
 *
 * @param    None.
 *
 * @return
 *        - XST_SUCCESS if example finishes successfully
 *        - XST_FAILURE if example fails.
 *
 * @note        None.
 *
 ******************************************************************************/
int main()
{
  int Status;

  xil_printf("\r\n--- Entering main() --- \r\n");

  /* Run the poll example for simple transfer */
  Status = XAxiDma_SimplePollExample(DMA_DEV_ID);

  if (Status != XST_SUCCESS) {

    xil_printf("XAxiDma_SimplePollExample: Failed\r\n");
    return XST_FAILURE;
  }

  xil_printf("XAxiDma_SimplePollExample: Passed\r\n");

  xil_printf("--- Exiting main() --- \r\n");

  return XST_SUCCESS;

}


/*****************************************************************************/
/**
 * The example to do the simple transfer through polling. The constant
 * NUMBER_OF_TRANSFERS defines how many times a simple transfer is repeated.
 *
 * @param    DeviceId is the Device Id of the XAxiDma instance
 *
 * @return
 *        - XST_SUCCESS if example finishes successfully
 *        - XST_FAILURE if error occurs
 *
 * @note        None
 *
 *
 ******************************************************************************/
int XAxiDma_SimplePollExample(u16 DeviceId)
{
  XAxiDma_Config *CfgPtr;
  int Status;
  u32 Index;
  u32 *TxBufferPtr;
  u32 *RxBufferPtr;
  u32 Value;


  TxBufferPtr = (u32 *)TX_BUFFER_BASE ;
  RxBufferPtr = (u32 *)RX_BUFFER_BASE;

  /* Initialize the XAxiDma device.
   */
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

  /* Disable interrupts, we use polling mode
   */
  XAxiDma_IntrDisable(&AxiDma, XAXIDMA_IRQ_ALL_MASK,
      XAXIDMA_DEVICE_TO_DMA);
  XAxiDma_IntrDisable(&AxiDma, XAXIDMA_IRQ_ALL_MASK,
      XAXIDMA_DMA_TO_DEVICE);

  Value = TEST_START_VALUE;

  for(Index = 0; Index < NUMBER_OF_WORDS; Index ++) {
    TxBufferPtr[Index] = Value;
    Value = Value + 1;
  }
  /* Flush the SrcBuffer before the DMA transfer, in case the Data Cache
   * is enabled
   */
  Xil_DCacheFlushRange((u32)TxBufferPtr, NUMBER_OF_BYTES);

  for(Index = 0; Index < NUMBER_OF_TRANSFERS; Index ++) {

    Status = XAxiDma_SimpleTransfer(&AxiDma,(u32) (RxBufferPtr + Index * 4),
    		4 * 4, XAXIDMA_DEVICE_TO_DMA);

    if (Status != XST_SUCCESS) {
      return XST_FAILURE;
    }


    Status = XAxiDma_SimpleTransfer(&AxiDma,(u32) (TxBufferPtr + Index * 4),
    		4 * 4, XAXIDMA_DMA_TO_DEVICE);

    if (Status != XST_SUCCESS) {
      return XST_FAILURE;
    }

    xil_printf("Waiting for AXI DMA \n\r");

    while (XAxiDma_Busy(&AxiDma,XAXIDMA_DMA_TO_DEVICE)) {
    	//wait
    }
    xil_printf("DMA_TO_DEVICE finishes \n\r");

    while (XAxiDma_Busy(&AxiDma,XAXIDMA_DEVICE_TO_DMA)) {
      //wait
    }
    xil_printf("DEVICE_TO_DMA finishes \n\r");

    Status = CheckData(Index);
    if (Status != XST_SUCCESS) {
      return XST_FAILURE;
    }

  }

  /* Test finishes successfully
   */
  return XST_SUCCESS;
}



/*****************************************************************************/
/*
 *
 * This function checks data buffer after the DMA transfer is finished.
 *
 * @param    None
 *
 * @return
 *
 * @note        None.
 *
 ******************************************************************************/
static int CheckData(u32 cur_indx)
{
  u32 *RxPacket;
  int Index = 0;

  RxPacket = (u32 *) (RX_BUFFER_BASE + cur_indx * 4 * 4);

  /* Invalidate the DestBuffer before receiving the data, in case the
   * Data Cache is enabled
   */
  Xil_DCacheInvalidateRange((u32)RxPacket, NUMBER_OF_BYTES);

  for(Index = 0; Index < 4; Index++) {
      xil_printf("Data %d: %x\r\n", Index, (unsigned int)RxPacket[Index]);
  }

  return XST_SUCCESS;
}
