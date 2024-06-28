function dydt = min_wage_model(t, y, employee_super, employer_super, super_growth)
    % Unpack the state variables
    salary = y(1); % Salary  (fixed)
    super_contrib = y(2); % Contribution to superannuation
    super = y(3);  % Superannuation 
       
    esct_tax_rate = esct_calc(salary); % employer super contribution is taxed
    total_super_contrib = employee_super + employer_super * (1 - esct_tax_rate); % super contribution is employee + employer contribution 
    
    % government contribution to superannuation
    if employee_super*salary > 1042
        govt_contrib = 541;
    else
        govt_contrib = 0.5*employee_super*salary;
    end
        
    dydt = zeros(2, 1);
    dydt(1) = 0; % Salary is constant
    dydt(2) = employee_super*salary;
    dydt(3) = total_super_contrib * salary + super_growth * super + govt_contrib; % Superannuation growth
end
