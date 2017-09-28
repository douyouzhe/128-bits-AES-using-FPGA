@echo off
rem  Vivado(TM)
rem  compile.bat: a Vivado-generated XSim simulation Script
rem  Copyright 1986-2014 Xilinx, Inc. All Rights Reserved.

set PATH=%XILINX%\lib\%PLATFORM%;%XILINX%\bin\%PLATFORM%;C:/DOUYOUZHE/APPLICATION/Xilinx/SDK/2014.2/bin;C:/DOUYOUZHE/APPLICATION/Xilinx/Vivado/2014.2/ids_lite/ISE/bin/nt64;C:/DOUYOUZHE/APPLICATION/Xilinx/Vivado/2014.2/ids_lite/ISE/lib/nt64;C:/DOUYOUZHE/APPLICATION/Xilinx/Vivado/2014.2/bin;%PATH%
set XILINX_PLANAHEAD=C:/DOUYOUZHE/APPLICATION/Xilinx/Vivado/2014.2

xelab -m64 --debug typical --relax -L xil_defaultlib -L secureip --snapshot myip_v1_0_behav --prj c:/users/douyouzhe/desktop/aes256version/ip_repo/myip_1.0/myip_v1_0_project/myip_v1_0_project.sim/sim_1/behav/myip_v1_0.prj   xil_defaultlib.myip_v1_0
if errorlevel 1 (
   cmd /c exit /b %errorlevel%
)
