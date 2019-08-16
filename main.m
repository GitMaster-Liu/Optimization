%% main函数
%% 载入参数
clear all;
clc;

%% 开始计算

pop=100;
gen=300;

typical_days = xlsread('LoadData-02.xlsx', 'Load', 'A3:J26');
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





M=3; %本次问题涉及四个目标
V=7; %决策变量共7位

min_range=[30,30,20,20,20,50,50];
% max_range = ones(1,V);
max_range=[140,140,390,340,100,400,400];

%% Initialize the population

%初始化种群，调用initialize_variables函数
%种群初始化做出调整，先初始化出
%chromosome = initialize_variables(pop, M, V, min_range, max_range);

%chromosome=zeros(pop, M+V);
load('chromosome_init.mat', 'chromosome');
fprintf("外层初始化结束");

%% Sort the initialized population
% Sort the population using non-domination-sort. This returns two columns
% for each individual which are the rank and the crowding distance
% corresponding to their position in the front they belong. At this stage
% the rank and the crowding distance for each chromosome is added to the
% chromosome vector for easy of computation.
% 非支配排序
%chromosome = non_domination_sort_mod(chromosome, M, V);

%% Start the evolution process
% The following are performed in each generation
% * Select the parents which are fit for reproduction
% * Perfrom crossover and Mutation operator on the selected parents
% * Perform Selection from the parents and the offsprings
% * Replace the unfit individuals with the fit individuals to maintain a
%   constant population size.

for i = 1 : gen
    fprintf("一次外层多目标优化");
    % Select the parents
    pool = round(pop/2);
    tour = 2;
    % Selection process
    % 带拥挤原则的非支配选择机制，选择标准是低支配级别和大拥挤距离，
    % tour代表几个个体同时进行比较，拥挤距离是染色体最后一位参数，支配级别是
    % 倒数第二位参数
    parent_chromosome = tournament_selection(chromosome, pool, tour);

    % 交叉和突变操作，交叉概率为0.9，突变概率为1/n，n就是这里的V即解空间维度
    mu = 20;
    mum = 20;
    offspring_chromosome = ...
        genetic_operator(parent_chromosome, ...
        M, V, mu, mum,min_range,max_range,winter_typical_day,summer_typical_day,transition_typical_day);
    for iii=1:pool
        
        solution= get_result( offspring_chromosome(1:V),winter_typical_day,summer_typical_day,transition_typical_day);%内层调用

        if norm(solution)==0
            offspring_chromosome(iii,V+1:V+3)=inf;
        else
            evaluate=evaluate(offspring_chromosome(1:V), solution, ...
                winter_typical_day,summer_typical_day,transition_typical_day);
            offspring_chromosome(iii,V+1) = evaluate(1);
            offspring_chromosome(iii,V+2) = evaluate(2);
            offspring_chromosome(iii,V+3) = evaluate(3);

        end
        %offspring_chromosome(iii,V+1:M+V)=evaluate_objective(offspring_chromosome(iii,1:V),M,V);
    end
    
    % Intermediate population
    % Intermediate population is the combined population of parents and
    % offsprings of the current generation. The population size is two
    % times the initial population.
    
    [main_pop,temp] = size(chromosome);
    [offspring_pop,temp] = size(offspring_chromosome);
    % temp is a dummy variable.
    clear temp
    % intermediate_chromosome is a concatenation of current population and
    % the offspring population.
    intermediate_chromosome(1:main_pop,:) = chromosome;
    intermediate_chromosome(main_pop + 1 : main_pop + offspring_pop,1 : M+V) = ...
        offspring_chromosome(1 : offspring_pop,1 : M+V);
    
    % Non-domination-sort of intermediate population
    % The intermediate population is sorted again based on non-domination sort
    % before the replacement operator is performed on the intermediate
    % population.
    intermediate_chromosome = ...
        non_domination_sort_mod(intermediate_chromosome, M, V);
    % Perform Selection
    % Once the intermediate population is sorted only the best solution is
    % selected based on it rank and crowding distance. Each front is filled in
    % ascending order until the addition of population size is reached. The
    % last front is included in the population based on the individuals with
    % least crowding distance
    % 选择操作
    chromosome = replace_chromosome(intermediate_chromosome, M, V, pop);
    %if ~mod(i,100)
        %clc
        %fprintf('%d generations completed\n',i);
    %end
    fprintf('%d generations completed\n',i);
end

save chromosome_cplex.mat

%% Result
% Save the result in ASCII text format.
save chromosome.txt chromosome -ASCII










