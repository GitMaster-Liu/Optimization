function f= checkall( population,winter_typical_day,summer_typical_day,transition_typical_day,cop_equipment )
[population_size,number_of_variables]=size(population);
clear number_of_variables;
f=true;
for i=1:population_size
    if ~check( population(i,:),winter_typical_day,summer_typical_day,transition_typical_day,cop_equipment )
        f=false;
        break;
    end
end
