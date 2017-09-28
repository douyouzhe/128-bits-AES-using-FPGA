#!/bin/sh
# Vivado(TM)
# compile.sh: Vivado-generated Script for launching XSim application
# Copyright 1986-2014 Xilinx, Inc. All Rights Reserved.
# 
if [ -z "$PATH" ]; then
  PATH=%XILINX%\lib\%PLATFORM%;%XILINX%\bin\%PLATFORM%:C:/DOUYOUZHE/APPLICATION/Xilinx/SDK/2014.2/bin;C:/DOUYOUZHE/APPLICATION/Xilinx/Vivado/2014.2/ids_lite/ISE/bin/nt64;C:/DOUYOUZHE/APPLICATION/Xilinx/Vivado/2014.2/ids_lite/ISE/lib/nt64
else
  PATH=%XILINX%\lib\%PLATFORM%;%XILINX%\bin\%PLATFORM%:C:/DOUYOUZHE/APPLICATION/Xilinx/SDK/2014.2/bin;C:/DOUYOUZHE/APPLICATION/Xilinx/Vivado/2014.2/ids_lite/ISE/bin/nt64;C:/DOUYOUZHE/APPLICATION/Xilinx/Vivado/2014.2/ids_lite/ISE/lib/nt64:$PATH
fi
export PATH

if [ -z "$LD_LIBRARY_PATH" ]; then
  LD_LIBRARY_PATH=:
else
  LD_LIBRARY_PATH=::$LD_LIBRARY_PATH
fi
export LD_LIBRARY_PATH

#
# Setup env for Xilinx simulation libraries
#
XILINX_PLANAHEAD=C:/DOUYOUZHE/APPLICATION/Xilinx/Vivado/2014.2
export XILINX_PLANAHEAD
ExecStep()
{
   "$@"
   RETVAL=$?
   if [ $RETVAL -ne 0 ]
   then
       exit $RETVAL
   fi
}

ExecStep xelab -m64 --debug typical --relax -L xil_defaultlib -L secureip --snapshot myip_v1_0_behav --prj c:/users/douyouzhe/desktop/aes256version/ip_repo/myip_1.0/myip_v1_0_project/myip_v1_0_project.sim/sim_1/behav/myip_v1_0.prj   xil_defaultlib.myip_v1_0
