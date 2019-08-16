%% main����
%% �������
tic
clear all;
clc;

%% ��ʼ����

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





M=4; %���������漰�ĸ�Ŀ��
V=7; %���߱�����7λ

min_range=[30,30,20,20,20,50,50];
% max_range = ones(1,V);
max_range=[140,140,390,340,100,400,400];

%% Initialize the population

%��ʼ����Ⱥ������initialize_variables����
%��Ⱥ��ʼ�������������ȳ�ʼ����
%chromosome = initialize_variables(pop, M, V, min_range, max_range);

chromosome=zeros(pop, M+V);
for i=1:pop
    chromosome(i,:)=Init_Capacity(winter_typical_day,summer_typical_day,transition_typical_day);%�����ʼ��ֻ��ʼ������N
    fprintf('�ѳ�ʼ��%d������\n',i);%��ʼ������Ⱦɫ������������ָ��
end
fprintf("����ʼ������");
toc