clear all;
close all;
clc;

%% Final Test BPCS - embedding

jpeg1=JPEGStegoObj('house-pbc.jpg');
Apply_BPCS(jpeg1, 'hello.txt');

%% Retrieving

jpeg2=JPEGStegoObj('house-pbc-embedded-BPCS.jpg');
Retrieve_Data_from_BPCS(jpeg2);

%% Final Test LSB - embedding

jpeg3=JPEGStegoObj('house-pbc.jpg');
Apply_LSB(jpeg3, 'hello.txt');

%% Retrieving

jpeg4=JPEGStegoObj('house-pbc-embedded-LSB.jpg');
Retrieve_Data_from_LSB(jpeg4);