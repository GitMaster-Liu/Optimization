%% main����
%% �������
clear all;
clc;

%% ��ʼ����

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





M=3; %���������漰�ĸ�Ŀ��
V=7; %���߱�����7λ

min_range=[30,30,20,20,20,50,50];
% max_range = ones(1,V);
max_range=[140,140,390,340,100,400,400];

%% Initialize the population

%��ʼ����Ⱥ������initialize_variables����
%��Ⱥ��ʼ�������������ȳ�ʼ����
%chromosome = initialize_variables(pop, M, V, min_range, max_range);

%chromosome=zeros(pop, M+V);
load('chromosome_init.mat', 'chromosome');
fprintf("����ʼ������");

%% Sort the initialized population
% Sort the population using non-domination-sort. This returns two columns
% for each individual which are the rank and the crowding distance
% corresponding to their position in the front they belong. At this stage
% the rank and the crowding distance for each chromosome is added to the
% chromosome vector for easy of computation.
% ��֧������
%chromosome = non_domination_sort_mod(chromosome, M, V);

%% Start the evolution process
% The following are performed in each generation
% * Select the parents which are fit for reproduction
% * Perfrom crossover and Mutation operator on the selected parents
% * Perform Selection from the parents and the offsprings
% * Replace the unfit individuals with the fit individuals to maintain a
%   constant population size.

for i = 1 : gen
    fprintf("һ������Ŀ���Ż�");
    % Select the parents
    pool = round(pop/2);
    tour = 2;
    % Selection process
    % ��ӵ��ԭ��ķ�֧��ѡ����ƣ�ѡ���׼�ǵ�֧�伶��ʹ�ӵ�����룬
    % tour����������ͬʱ���бȽϣ�ӵ��������Ⱦɫ�����һλ������֧�伶����
    % �����ڶ�λ����
    parent_chromosome = tournament_selection(chromosome, pool, tour);

    % �����ͻ��������������Ϊ0.9��ͻ�����Ϊ1/n��n���������V����ռ�ά��
    mu = 20;
    mum = 20;
    offspring_chromosome = ...
        genetic_operator(parent_chromosome, ...
        M, V, mu, mum,min_range,max_range,winter_typical_day,summer_typical_day,transition_typical_day);
    for iii=1:pool
        
        solution= get_result( offspring_chromosome(1:V),winter_typical_day,summer_typical_day,transition_typical_day);%�ڲ����

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
    % ѡ�����
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










