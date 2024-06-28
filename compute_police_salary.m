function [current_salary,employee_super,employer_super] = compute_police_salary(t, salary_data)
    
    index = round(t) + 1;
    if index > length(salary_data)
        total_renumeration = salary_data(end);
    else
        total_renumeration = salary_data(index);
    end

    ins_sub = 208; % insurance subsidy
    pct = 863; % physical competence test
    employer_super_contrib = 10.184/100; % employer super contribution (after tax)
    employee_super_contrib = 7.5/100; % employee super contribution
      
    tmp = total_renumeration - ins_sub - pct;
    salary = tmp/(1+employer_super_contrib); % this includes employee superannuation contribution
    

    current_salary = salary;
    employee_super = current_salary * employee_super_contrib; 
    employer_super = current_salary * employer_super_contrib; 
