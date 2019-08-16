for i=1:100

[initial_outlay(i), year_gas_cost(i), year_ele_cost(i), year_maintenance_cost(i)] = get_cost(chromosome(i,1:7), elite(i,:), elite_follow(i,:),winter_typical_day,summer_typical_day,transition_typical_day);

end