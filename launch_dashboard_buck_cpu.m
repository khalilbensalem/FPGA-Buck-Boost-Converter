clc;
clear;

duty = 0.5;
freq = 52300;
rst = 0;
en = 1;
mode = 0;
vref = 5;

open_system('gmStateSpaceHDL_buck_convert_test1_fixpt_test_registr');

app = Dashboard_App;