function [salary, repayment_amount, salary_after_repayments, loan_change, employee_super_contrib] = compute_current_salary(t, uni_years, uni_fees, salary_data, employee_super, loan_balance, repayment_threshold, repayment_rate, placement_hours, min_wage_hourly)
    % Calculate the current salary from the salary data
  
    if t < uni_years
        salary = 0;
        salary_after_repayments = 0;
        loan_change = uni_fees + placement_hours * min_wage_hourly;
        repayment_amount = 0;
        employee_super_contrib = 0;
    else
        index = round(t - uni_years) + 1;
        if index > length(salary_data)
            salary = salary_data(end); 
        else
            salary = salary_data(index);
        end

        employee_super_contrib = salary * employee_super;
        
        if loan_balance > 0 && salary > repayment_threshold
            repayment_amount = repayment_rate * (salary - repayment_threshold);
            salary_after_repayments = salary - repayment_amount;
            loan_change = -repayment_amount;
        else
            repayment_amount = 0;
            salary_after_repayments = salary - repayment_amount;
            loan_change = 0;
        end
    end
end
