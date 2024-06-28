function dydt = firefighter_model(t, y, salary_data, super_growth)
    super = y(2);  % Superannuation 
    
    % compute current salary
    [current_salary,employee_super,employer_super] = compute_firefighter_salary(t, salary_data);
    
    esct_tax_rate = esct_calc(current_salary); % employer super contribution is taxed
    employer_super_after_tax = (1 - esct_tax_rate) * employer_super;

    dydt = zeros(2, 1);
    dydt(1) = 0; % Salary is provided by the salary data
    dydt(2) = super_growth * super + employee_super + employer_super_after_tax; % Superannuation growth
end
