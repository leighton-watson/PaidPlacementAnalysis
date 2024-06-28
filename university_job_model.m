function dydt = university_job_model(t, y, salary_data, employee_super, employer_super, super_growth, uni_years, uni_fees, placement_hours, min_wage_hourly, repayment_threshold, repayment_rate)
    % Unpack the state variables
    salary = y(1);     % Salary
    super = y(2);      % Superannuation 
    loan = y(3);      % Student loan 

    % compute current salary
    [current_salary, ~, ~, loan_change, ~] = compute_current_salary(t, uni_years, uni_fees, salary_data, employee_super, loan, repayment_threshold, repayment_rate, placement_hours, min_wage_hourly);
   
    esct_tax_rate = esct_calc(current_salary); % employer super contribution is taxed
    total_super_contrib = employee_super + employer_super * (1 - esct_tax_rate); % super contribution is employee + employer contribution 

    % government contribution to superannuation
    if employee_super*current_salary > 1042
        govt_contrib = 541;
    else
        govt_contrib = 0.5*employee_super*current_salary;
    end
    
    dydt = zeros(3, 1);
    dydt(1) = 0; % Salary is provided by the salary data
    dydt(2) = total_super_contrib * current_salary + super_growth * super + govt_contrib; % Superannuation growth
    dydt(3) = loan_change; % Student loan accumulation during university years
end
