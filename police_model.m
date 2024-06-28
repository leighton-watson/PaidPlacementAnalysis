function dydt = police_model(t, y, salary_data, super_growth)
    super = y(2);  % Superannuation 
    
    % compute current salary
    [current_salary,employee_super,employer_super] = compute_police_salary(t, salary_data);
    
    dydt = zeros(2, 1);
    dydt(1) = 0; % Salary is provided by the salary data
    dydt(2) = super_growth * super + employee_super + employer_super; % Superannuation growth
end
