%% Identifying breaks in trend

% This file aims to construct our "Empirical Fact" figure: a figure that
% shows that some measure of "investment in learning" (--> that increases
% the endogenous component of TFP), which we simply refer to as "IT",
% exhibits a break in the trend around 2005-6, so that what is relevant for
% the evolution of TFP is NOT the cyclical variation in this variable, but
% the trend.

%% Read in a series
clear all


lessors = 'data_trendbreaks.xlsx';
lessors_sheet ='Sheet1';
lessors_range = 'B2:B333';
time_range = 'A2:A333';

file = lessors;
sheet = lessors_sheet;
range = lessors_range;
data = xlsread(lessors,sheet,range);
date_numbers_excel = xlsread(lessors,sheet,time_range);

datenumbers = x2mdate(date_numbers_excel,0);
periods = datestr(datenumbers, 'yyyy-mm');

plot(data)

% Create a moving average smoothed trend
weigths = [1/24;repmat(1/12,11,1);1/24]; % choosing 1/24 weights for end terms, 1/12 weight for interior ones b/c data is monthly
trend = conv(data,weigths,'valid'); % 'valid'  leaves out the end observations as those cannot be smoothed and would thus distort things
trend = vertcat([nan nan nan nan nan nan]', trend, [nan nan nan nan nan nan]');

figure(1)
hold on
plot( data,'b', 'linewidth', 2)
plot(trend, 'r', 'linewidth', 2)
% datetick('x', 'yyyy-mm', 'keepticks')
grid on
hold off
