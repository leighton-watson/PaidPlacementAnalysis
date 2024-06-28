function post_tax_salaries = calculate_post_tax_salary(pre_tax_salaries)
    % Define tax brackets and corresponding tax rates
    tax_brackets = [15600, 53500, 78100, 180000];
    tax_rates = [0.105, 0.175, 0.30, 0.33, 0.39];

    % Initialize post-tax salary array
    post_tax_salaries = zeros(size(pre_tax_salaries));

    % Iterate over each pre-tax salary
    for i = 1:numel(pre_tax_salaries)
        salary = pre_tax_salaries(i);
        if salary <= tax_brackets(1)
            post_tax_salary = salary * (1 - tax_rates(1));
        elseif salary <= tax_brackets(2)
            post_tax_salary = tax_brackets(1) * (1 - tax_rates(1)) + (salary - tax_brackets(1)) * (1 - tax_rates(2));
        elseif salary <= tax_brackets(3)
            post_tax_salary = tax_brackets(1) * (1 - tax_rates(1)) + (tax_brackets(2) - tax_brackets(1)) * (1 - tax_rates(2)) + (salary - tax_brackets(2)) * (1 - tax_rates(3));
        elseif salary <= tax_brackets(4)
            post_tax_salary = tax_brackets(1) * (1 - tax_rates(1)) + (tax_brackets(2) - tax_brackets(1)) * (1 - tax_rates(2)) + (tax_brackets(3) - tax_brackets(2)) * (1 - tax_rates(3)) + (salary - tax_brackets(3)) * (1 - tax_rates(4));
        else
            post_tax_salary = tax_brackets(1) * (1 - tax_rates(1)) + (tax_brackets(2) - tax_brackets(1)) * (1 - tax_rates(2)) + (tax_brackets(3) - tax_brackets(2)) * (1 - tax_rates(3)) + (tax_brackets(4) - tax_brackets(3)) * (1 - tax_rates(4)) + (salary - tax_brackets(4)) * (1 - tax_rates(5));
        end

        post_tax_salaries(i) = post_tax_salary;
    end
end
