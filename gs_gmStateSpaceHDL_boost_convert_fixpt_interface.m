%--------------------------------------------------------------------------
% Host Interface Script
% 
% Generated with MATLAB 25.1 (R2025a) at 15:58:49 on 12/04/2026.
% This script was created for the IP Core generated from design 'gmStateSpaceHDL_boost_convert_fixpt'.
% 
% Use this script to access DUT ports in the design that were mapped to compatible IP core interfaces.
% You can write to input ports in the design and read from output ports directly from MATLAB.
% To write to input ports, use the "writePort" command and specify the port name and input data. The input data will be cast to the DUT port's data type before writing.
% To read from output ports, use the "readPort" command and specify the port name. The output data will be returned with the same data type as the DUT port.
% Use the "release" command to release MATLAB's control of the hardware resources.
%--------------------------------------------------------------------------

%% Program FPGA
% Uncomment the lines below to program FPGA hardware with the designated bitstream and configure the processor with the corresponding devicetree.
% MATLAB will connect to the board with an SSH connection to program the FPGA.
% If you need to change login parameters for your board, use the following syntax:
% hProcessor = xilinxsoc(ipAddress, username, password);
hProcessor = xilinxsoc();
% programFPGA(hProcessor, "C:\Users\bensa\Desktop\PI3_FPGA_BuckConverter\TESTT_VF_fixpt_AXI_test\hdl_Boost\vivado_ip_prj\vivado_prj.runs\impl_1\design_1_wrapper.bit", "");

%% Create fpga object
hFPGA = fpga(hProcessor);

%% Setup fpga object
% This function configures the "fpga" object with the same interfaces as the generated IP core
gs_gmStateSpaceHDL_boost_convert_fixpt_setup(hFPGA);

%% Write/read DUT ports
% Uncomment the following lines to write/read DUT ports in the generated IP Core.
% Update the example data in the write commands with meaningful data to write to the DUT.
%% AXI4-Lite
% writePort(hFPGA, "rst", zeros([1 1]));
% writePort(hFPGA, "duty_open_loop", zeros([1 1]));
% writePort(hFPGA, "freq", zeros([1 1]));
% writePort(hFPGA, "en", zeros([1 1]));
% writePort(hFPGA, "mode_controller", zeros([1 1]));
% writePort(hFPGA, "vout_ref", zeros([1 1]));
% data_vin_axi = readPort(hFPGA, "vin_axi");
% data_vout_axi = readPort(hFPGA, "vout_axi");
% data_pwm_axi = readPort(hFPGA, "pwm_axi");
% data_error_axi = readPort(hFPGA, "error_axi");

%% Release hardware resources
release(hFPGA);

