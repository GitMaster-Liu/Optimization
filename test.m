load chromosome_best.mat
tic
best_fitness=[];
elite=[];
generation=[];
elite_follow=[];
for i=1:pop
    [best_fitness(:,i), elite(i,:), generation(i),elite_follow(i,:)] = my_ga(chromosome(i,1:7), 'my_fitness', 1000, 500, 0, 500,winter_typical_day,summer_typical_day,transition_typical_day);
end
save chromosome_best.mat
toc