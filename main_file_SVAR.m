%Run a SVAR and identify news shocks and R&D shocks

% Marco Brianti, Laura G�ti, Sep 28 2017

clear all
close all

%Data Reading and Transformation
data = xlsread('dataset_23_sept_2017','Sheet1','B126:I283');
% Cumulate growth variables to levels (log levels to be precise, b/c growth
% rates are calculated as log diffs)
data_levels(:,1) = cumsum(data(:,1)); % TFP
% data_levels(:,1) = data(:,1); % TFP % I tried TFP grt.
data_levels(:,3) = log(data(:,2)); % this series was levels to start out with so don't cumsum <-- taking logs here induces stationarity of VAR - DISCUSS! If VAR nonstat and not cointegrated, estimation not possible.
% 2 is R&D, 5 means we take IT investment instead of R&D
data_levels(:,2) = data(:,4); % the Mich index
data_levels(:,4) = data(:,6); % real GDP % whether this guy's in logs or not doesn't seem to make a diff
data_levels(:,5) = data(:,7); % real cons % whether this guy's in logs or not doesn't seem to make a diff
data_levels(:,4) = log(data(:,6)); % real GDP % whether this guy's in logs or not doesn't seem to make a diff
data_levels(:,5) = log(data(:,7)); % real cons % whether this guy's in logs or not doesn't seem to make a diff
data_levels(:,6) = data(:,8); %hours worked

% % Have an initial look at data
% figure
% hold on
% plot(data_levels(:,1),'k')
% plot(data_levels(:,2), 'b')
% plot(data_levels(:,3), 'r')
% plot(data_levels(:,4), 'g')
% grid on
% hold off

% TO DO: implement lag selection (AIC, BIC) (see 'Lecture2M' in our folder)
max_lags   = 10;
nburn      = 200;
nsimul     = 500; %5000
nvar       = size(data_levels,2);

%%Checking the number of lags over BIC, AIC, and HQ - TO BE FINISHED
[AIC,BIC,HQ] = aic_bic_hq(data_levels,max_lags);

%Run VAR imposing Cholesky
nlags = 4;
[A,B,res] = sr_var(data_levels, nlags);

%Checking if the VAR is stationary
test_stationarity(B');

% Generate bootstrapped data samples
which_correction = 'none'; % [none, blocks] --> how to improve on the Bootstrap
dataset_boot = data_boot(B, nburn, res, nsimul, which_correction,5);
% TO DO: draw shocks in blocks

% Redo VAR nsimul times on the bootstrapped datasets
A_boot = zeros(nvar,nvar,nsimul);
B_boot = zeros(nvar*nlags+1,nvar,nsimul);
for i_simul = 1:nsimul
      [A_boot(:,:,i_simul), B_boot(:,:,i_simul), ~] = sr_var(dataset_boot(:,:,i_simul), nlags);
end

% %Kilian correction - IT IS NOT WORKING VERY NICELY. DONT KNOW WHY!
% for i_simul = 1:nsimul
%       average_B_boot = mean(B_boot,3);
%       average_A_boot = mean(A_boot,3);
%       B_boot(:,:,i_simul) = 2*B_boot(:,:,i_simul) - average_B_boot;
%       A_boot(:,:,i_simul) = 2*A_boot(:,:,i_simul) - average_A_boot;
% end

%Calculate IRFs, bootstrapped CI and plot them
h=40;
which_shock = [2 3];
names = {'News shock','R&D shock'}; % shock names in order of appearance
% varnames = {'TFP','Mich index','R&D'} ; % variable names in order of appearance
% varnames = {'TFP','Mich index','R&D', 'GDP'} ; % alternative specs 1
% varnames = {'TFP','Mich index','R&D', 'GDP', 'C'} ; % alternative specs 2
varnames = {'TFP','Mich index','R&D', 'GDP', 'C', 'H'} ; % alternative specs 3

sig = 0.90; % significance level
H = 100; % horizon for generation of IRFs
[IRFs, ub, lb] = genIRFs(A,A_boot,B,B_boot,H, sig);

plotIRFs(IRFs,ub,lb,h,which_shock, names, varnames)

% Variance decomposition
 m = 24; %Horizon of the variance decomposition explained by the shocks
[vardec] = gen_vardecomp(IRFs,m,H);
[vardec_table] = vardecomp_table(vardec,which_shock,varnames,names);

%------------------------------------------------------------------------------------------


