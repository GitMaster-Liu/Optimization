%% main函数
%% 载入参数
tic
clear all;
clc;

%% 开始计算

pop=10;
gen=20;

typical_days = xlsread('LoadData(2).xlsx', 'Load', 'A3:J26');
winter_typical_day = typical_days(:,1:3);
winter_typical_day(:,1)=0.01*winter_typical_day(:,1);
winter_typical_day(:,2)=0.01*winter_typical_day(:,2);
summer_typical_day = typical_days(:,4:6);
summer_typical_day(:,1)=0.01*summer_typical_day(:,1);
summer_typical_day(:,2)=0.01*summer_typical_day(:,2);
transition_typical_day = typical_days(:,7:10);
transition_typical_day(:,1)=0.01*transition_typical_day(:,1);
transition_typical_day(:,2)=0.01*transition_typical_day(:,2);
transition_typical_day(:,3)=0.01*transition_typical_day(:,3);





M=4; %本次问题涉及四个目标
V=7; %决策变量共7位

min_range=[30,30,20,20,20,50,50];
% max_range = ones(1,V);
max_range=[140,140,390,340,100,400,400];

%% Initialize the population

%初始化种群，调用initialize_variables函数
%种群初始化做出调整，先初始化出
%chromosome = initialize_variables(pop, M, V, min_range, max_range);

chromosome=zeros(pop, M+V);
for i=1:pop
    chromosome(i,:)=Init_Capacity(winter_typical_day,summer_typical_day,transition_typical_day);%这里初始化只初始化容量N
    fprintf('已初始化%d个个体\n',i);%初始化会在染色体最后加上评价指标
end
fprintf("外层初始化结束");
toc