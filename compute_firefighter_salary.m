function [current_salary,employee_super,employer_super] = compute_firefighter_salary(t, salary_data)
    
    index = round(t) + 1;
    if index > length(salary_data)
        salary = salary_data(end);
    else
        salary = salary_data(index);
    end

    employer_super_contrib = 9/100; % employer super contribution (after tax)
    employee_super_contrib = 6/100; % employee super contribution
      
    current_salary = salary;
    employee_super = current_salary * employee_super_contrib; 
    employer_super = current_salary * employer_super_contrib; 
