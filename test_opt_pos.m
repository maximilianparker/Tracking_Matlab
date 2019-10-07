clear
num=61;
Fs_orig=60; % original sampling frequency
Fs=600; % sampling frequency
Ts=0.0016667; % Sample rate

%% Optim bounds
% Read CSV file
M = xlsread('T_8.xlsx');
r = M(:,3); % target positions
y = M(:,2); % cursor positions

% generate target and cursor velocity traces
h=1;
r_v=diff(r)/h;
y_v=diff(y)/h;
r_v(2:end+1)=r_v; % target velocity
y_v(2:end+1)=y_v; % cursor velocity


T=150;  % Delay parameter (ms)

% params (Gain,ref,damp)
x0=[100,0,0];

yhat_v=y_v(1:(500)); % make first 500 samples of yhat (predictions) same as y: VELOCITY PREDICTIONS
yhat_p=y(1:(500)); % make first 500 samples of yhat (predictions same as y: POSITION PREDICTIONS

lb=[1,0,0]; % lower bounds for parameters
ub=[2000,0,1]; % upper bounds for parameters

%% parameter estimation
% set function to optimise and necessary inputs
test=@(x0)test_model_pos(x0,y,r,y_v,r_v,T);

% optimisation options
opt = optimoptions('lsqnonlin', 'MaxIter', 2000, 'MaxFunEvals', 2000, 'TolFun', 1e-7);

% Optimise
theta(:) = lsqnonlin(test, x0, lb, ub, opt); % theta= new parameter values

%% run the model with the best parameter set to generate residual error (e)
[e,~,yhat_p,yhat_v] = test_model_cont(theta,y,r,y_v,r_v,T); 

% generate RMSE (position and velocity)
rms(yhat_p-y)
rms(yhat_v-y_v)

%% PLOTS
% % figure(1);
% % plot(1:3840,t,1:3840,c,1:3840,pos_yhat)
% % figure(2);
% % plot(1:3840,vel_c,1:3840,yhat)
figure(3);plot(1:length(y),y,'r',1:length(y),yhat_p,'-b')
title 'Continuous Model: Position'
figure(4);plot(1:length(y),y_v,'r',1:length(y),yhat_v,'-b')
title 'Continuous Model: Velocity' 
% % val=400
% % figure(1);plot(1:val,y(1:val),1:val,yhat_p)
% % figure(2);plot(1:val,y_v(1:val),1:val,yhat_v)
% e=yhat_v-y_v;

% rms(e)
