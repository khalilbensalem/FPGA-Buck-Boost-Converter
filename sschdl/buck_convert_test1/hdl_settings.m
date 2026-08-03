%% Set Model 'gmStateSpaceHDL_buck_convert_test1_fixpt' HDL parameters
hdlset_param('gmStateSpaceHDL_buck_convert_test1_fixpt', 'AutoRoute', 'off');
hdlset_param('gmStateSpaceHDL_buck_convert_test1_fixpt', 'DistributedPipelining', 'on');
hdlset_param('gmStateSpaceHDL_buck_convert_test1_fixpt', 'FPToleranceValue', 1.000000e-03);
fpconfig = hdlcoder.createFloatingPointTargetConfig('NATIVEFLOATINGPOINT' ...
, 'LatencyStrategy', 'Min' ...
);
hdlset_param('gmStateSpaceHDL_buck_convert_test1_fixpt', 'FloatingPointTargetConfiguration', fpconfig);
hdlset_param('gmStateSpaceHDL_buck_convert_test1_fixpt', 'HDLSubsystem', 'gmStateSpaceHDL_buck_convert_test1_fixpt/HDL Subsystem');
hdlset_param('gmStateSpaceHDL_buck_convert_test1_fixpt', 'MaskParameterAsGeneric', 'on');
hdlset_param('gmStateSpaceHDL_buck_convert_test1_fixpt', 'ProjectFolder', 'C:\Users\bensa\Desktop\PI3_FPGA_BuckConverter\V2\hdl_Buck');
hdlset_param('gmStateSpaceHDL_buck_convert_test1_fixpt', 'ReferenceDesign', 'Reference Design');
hdlset_param('gmStateSpaceHDL_buck_convert_test1_fixpt', 'ReferenceDesignParameter', {'NbDaqChannels','0','NbAnalogOutputs','0','NbStreamInputs','0','HDLVerifierAXI','off','HDLVerifierFDC','JTAG'});
hdlset_param('gmStateSpaceHDL_buck_convert_test1_fixpt', 'SynthesisTool', 'Xilinx Vivado');
hdlset_param('gmStateSpaceHDL_buck_convert_test1_fixpt', 'SynthesisToolChipFamily', 'Zynq');
hdlset_param('gmStateSpaceHDL_buck_convert_test1_fixpt', 'SynthesisToolDeviceName', 'xc7z020');
hdlset_param('gmStateSpaceHDL_buck_convert_test1_fixpt', 'SynthesisToolPackageName', 'clg484');
hdlset_param('gmStateSpaceHDL_buck_convert_test1_fixpt', 'SynthesisToolSpeedValue', '-1');
hdlset_param('gmStateSpaceHDL_buck_convert_test1_fixpt', 'TargetDirectory', 'C:\Users\bensa\Desktop\PI3_FPGA_BuckConverter\V2\hdl_Buck\hdlsrc');
hdlset_param('gmStateSpaceHDL_buck_convert_test1_fixpt', 'TargetFrequency', 40);
hdlset_param('gmStateSpaceHDL_buck_convert_test1_fixpt', 'TargetPlatform', 'Eclypse Z7 (NOA Toolbox)');
hdlset_param('gmStateSpaceHDL_buck_convert_test1_fixpt', 'TreatRatesAsHardwareRates', 'on');
hdlset_param('gmStateSpaceHDL_buck_convert_test1_fixpt', 'UseFloatingPoint', 'on');
hdlset_param('gmStateSpaceHDL_buck_convert_test1_fixpt', 'Workflow', 'IP Core Generation');

hdlset_param('gmStateSpaceHDL_buck_convert_test1_fixpt/HDL Subsystem/HDL Algorithm/Mode Selection/Generate Mode Vector/Generate Mode Vector_FixPt', 'Architecture', 'MATLAB Datapath');

