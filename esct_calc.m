function esct_tax_rate = esct_calc(salary)
    % ESCT threshold amounts and rates
    thresholds = [0, 16800, 57600, 84000, 216000];
    rates = [0.105, 0.175, 0.30, 0.33, 0.39];

    % Find the index of the appropriate tax bracket
    bracket_index = find(salary > thresholds, 1, 'last');
    
    % If salary is above the highest threshold, use the highest rate
    if isempty(bracket_index)
        esct_tax_rate = rates(end);
    else
        % Otherwise, use the rate corresponding to the found bracket
        esct_tax_rate = rates(bracket_index);
    end
end
