%% Salary and Superannuation %%
clear all; %clc;
set(0,'DefaultAxesFontSize',12)
set(0,'DefaultLineLineWidth',3)
cmap = get(gca,'ColorOrder');
figure(1); clf;

%% Load data and format parameters %%

% load salary data
salary_table_unpaid = readtable('unpaid_training_salaries.xlsx');
salary_table_paid = readtable('paid_training_salaries.xlsx');

% load unpaid training parameters
parameters_table = readtable('unpaid_training_parameters.xlsx');

% Time span for simulation (in years)
tspan = [0, 47]; % simulation time window
tplot = [0, 20]; % plot time window
tstep = 0.01;
TIME = min(tspan):tstep:max(tspan); % time vector to interpolate on

% initialize dataframes to store outputs
num_jobs = 4;
LOAN = zeros(length(TIME),num_jobs);
REPAYMENTS = zeros(length(TIME),num_jobs);
SALARY = zeros(length(TIME),num_jobs);
SUPER = zeros(length(TIME),num_jobs);
SUPER_CONTRIB = zeros(length(TIME),num_jobs);
JOB = {};

% Parameters
min_wage = 48152;
min_wage_hourly = 23.15;
employee_super = 0.03;
employer_super = 0.03;
super_growth = 0.05;
repayment_threshold = 24128;
repayment_rate = 0.12;

% Initial conditions for minimum wage worker
initial_salary = min_wage; % Initial salary  (fixed)
initial_super_contrib = 0; % Initial superannuation contribution
initial_super = 0; % Initial superannuation 
initial_cond = [initial_salary, initial_super_contrib, initial_super]; % Initial conditions

% Solve the differential equations for minimum wage job
[t, y] = ode45(@(t, y) min_wage_model(t, y, employee_super, employer_super, super_growth), tspan, initial_cond);

% Extract solutions
salary = y(:, 1); % salary (before tax and superannuation contributions)
super_contrib = salary * employee_super; % employee superannuation contributions paid each year
super = y(:, 3); % superannuation balance

% interpolate and save
min_salary = interp1(t,salary,TIME);
min_super = interp1(t,super,TIME);
min_super_contrib = interp1(t,super_contrib,TIME);
JOB(1) = {'MinWage'};



%% Unpaid University Training %%

job_names = salary_table_unpaid.Properties.VariableNames(2:end); % Exclude the first column 'Step'
for k = 1:2
    for j = 1:length(job_names)
        job_name = job_names{j};
        salary_data = salary_table_unpaid{:, job_name};

        % Extract parameters for the current job
        job_params = parameters_table(strcmp(parameters_table.Job, job_name), :);
        uni_years = job_params.TimeUni;
        uni_fees = job_params.UniCost;
        if k == 1
            placement_hours = 0;
        else
            placement_hours = job_params.PlacementHoursYearly;
        end

        % Initial conditions for each job
        initial_salary = 0; % Initial salary for job (starts unpaid)
        initial_super = 0; % Initial superannuation for job
        initial_loan = 0; % Initial student loan for job
        initial_cond = [initial_salary, initial_super, initial_loan]; % Initial conditions

        % Solve the differential equations for each job
        [t, y] = ode45(@(t, y) university_job_model(t, y, salary_data, employee_super, employer_super, super_growth, uni_years, uni_fees, placement_hours, min_wage_hourly, repayment_threshold, repayment_rate), tspan, initial_cond);

        % Extract solutions
        super = y(:, 2);
        loan = y(:, 3);
        salary = zeros(size(t));
        repayments = zeros(size(t));
        salary_after_repayments = zeros(size(t));
        super_contrib = zeros(size(t));
        loan_balance = zeros(size(t));
        for i = 1:length(t)
            loan_balance = loan(i);
            [current_salary, repayment_amount, salary_after_repayments, loan_change, employee_super_contrib] = compute_current_salary(t(i), uni_years, uni_fees, salary_data, employee_super, loan_balance, repayment_threshold, repayment_rate, placement_hours, min_wage_hourly);
            repayments(i) = repayment_amount;
            salary_after_repayments(i) = salary_after_repayments;
            salary(i) = current_salary;
            super_contrib(i) = employee_super_contrib;
        end

        % interpolate and save
        SALARY(:,j) = interp1(t,salary,TIME);
        SUPER_CONTRIB(:,j) = interp1(t,super_contrib,TIME);
        LOAN(:,j) = interp1(t,loan,TIME);
        REPAYMENTS(:,j) = interp1(t,repayments,TIME);
        JOB(j) = {job_name};

    end


    %% Plotting

    figHand = figure(1); 
    set(figHand,'Position',[100 100 1400 1200])
    cmap2 = [cmap(3,:);cmap(4,:);cmap(5,:);cmap(6,:)];
    for j = 1:num_jobs
        % loan
        subplot(2,2,2*k-1);
        plot(TIME,LOAN(:,j),'Color',cmap2(j,:)); hold on;
        ylabel('Student Loans ($)');
        ylim([0 1e5])
        

        % repayments
        subplot(2,2,2*k);
        plot(TIME,REPAYMENTS(:,j),'Color',cmap2(j,:)); hold on;
        ylabel('Annual Repayments ($)')
        title('Student Loan Repayments')
        ylim([0 10000])
    end

end

%% format plots
for l = 1:4
    subplot(2,2,l);
    xlim(tplot);
    grid on;
    xlabel('Time (years)')
end

subplot(2,2,1); title('(a) Loan Balance'); legend(JOB,'location','NorthEast')
subplot(2,2,2); title('(b) Student Loan Repayments'); legend(JOB,'location','SouthEast')
subplot(2,2,3); title('(c) Loan Balance'); legend(JOB,'location','NorthEast')
subplot(2,2,4); title('(d) Student Loan Repayments'); legend(JOB,'location','SouthEast')

subplot(2,2,1);
text(0.0, 1.15, 'Student loan balance and repayments when borrowing course fees', ...
    'Units', 'normalized', 'FontSize', 16, 'FontWeight', 'bold');

subplot(2,2,3)
text(0.0, 1.15, 'Student loan balance and repayments when borrowing course fees and living expenses (placement hours)', ...
    'Units', 'normalized', 'FontSize', 16, 'FontWeight', 'bold');




