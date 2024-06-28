%% Salary and Superannuation %%
clear all; clc;
set(0,'DefaultAxesFontSize',12)
set(0,'DefaultLineLineWidth',3)
cmap = get(gca,'ColorOrder');
figHand = figure(1); clf;
set(figHand,'Position',[100 100 1400 1200])
lstyle = {'-',':','-.'};

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
num_jobs = 7;
SALARY = zeros(length(TIME),num_jobs);
SUPER = zeros(length(TIME),num_jobs);
SUPER_CONTRIB = zeros(length(TIME),num_jobs);
REPAYMENTS = zeros(length(TIME),num_jobs);
JOB = {};

% Parameters
min_wage = 48152;
min_wage_hourly = 23.15;
employee_super = 0.03;
employer_super = 0.03;
super_growth = 0.03;
repayment_threshold = 24128;
repayment_rate = 0.12;
SUPER_GROWTH = 0.5;

for kk = 1:length(SUPER_GROWTH)
    super_growth = SUPER_GROWTH(kk)
    kk


    %% Minimum Wage %%

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
    SALARY(:,1) = interp1(t,salary,TIME);
    SUPER(:,1) = interp1(t,super,TIME);
    SUPER_CONTRIB(:,1) = interp1(t,super_contrib,TIME);
    JOB(1) = {'MinWage'};




    %% Police %%

    job_name = 'Police';
    salary_data = salary_table_paid{:, job_name};

    % Initial conditions for each job
    initial_salary = salary_data(1); % Initial salary for job
    initial_super = 0; % Initial superannuation for job
    initial_cond = [initial_salary, initial_super]; % Initial conditions

    % Solve the differential equations for each job
    [t, y] = ode45(@(t, y) police_model(t, y, salary_data, super_growth), tspan, initial_cond);

    % Extract solutions
    salary = zeros(size(t));
    super_contrib = zeros(size(t));
    for i = 1:length(t)
        [current_salary,employee_super_contrib,~] = compute_police_salary(t(i),salary_data);
        salary(i) = current_salary; % salary
        super_contrib(i) = employee_super_contrib; % employee superannuation contributions
    end
    super = y(:, 2); % superannuation


    % interpolate and save
    SALARY(:,2) = interp1(t,salary,TIME);
    SUPER(:,2) = interp1(t,super,TIME);
    SUPER_CONTRIB(:,2) = interp1(t,super_contrib,TIME);
    JOB(2) = {job_name};

    %% Firefighter

    job_name = 'Firefighter';
    salary_data = salary_table_paid{:, job_name};

    % Initial conditions for each job
    initial_salary = salary_data(1); % Initial salary for job
    initial_super = 0; % Initial superannuation for job
    initial_cond = [initial_salary, initial_super]; % Initial conditions

    % Solve the differential equations for each job
    [t, y] = ode45(@(t, y) firefighter_model(t, y, salary_data, super_growth), tspan, initial_cond);

    % Extract solutions
    salary = zeros(size(t));
    super_contrib = zeros(size(t));
    for i = 1:length(t)
        [current_salary,employee_super_contrib,~] = compute_firefighter_salary(t(i),salary_data);
        salary(i) = current_salary; % salary
        super_contrib(i) = employee_super_contrib; % employee superannuation contributions
    end
    super = y(:, 2); % superannuation

    % interpolate and save
    SALARY(:,3) = interp1(t,salary,TIME);
    SUPER(:,3) = interp1(t,super,TIME);
    SUPER_CONTRIB(:,3) = interp1(t,super_contrib,TIME);
    JOB(3) = {job_name};


    POSTTAX_SALARY = calculate_post_tax_salary(SALARY);
    POSTTAX_AND_SUPERCONTRIB_SALARY = POSTTAX_SALARY - SUPER_CONTRIB - REPAYMENTS;
    CUM_SALARY = zeros(size(SALARY));
    for j = 1:num_jobs
        cum_salary = cumtrapz(TIME,POSTTAX_AND_SUPERCONTRIB_SALARY(:,j));
        CUM_SALARY(:,j) = cum_salary;
    end

    police_cum_salary = CUM_SALARY(:,2);
    fire_cum_salary = CUM_SALARY(:,3);


    %% Unpaid University Training %%

    job_names = salary_table_unpaid.Properties.VariableNames(2:end); % Exclude the first column 'Step'

    for j = 1:length(job_names)
        job_name = job_names{j};
        salary_data = salary_table_unpaid{:, job_name};

        % Extract parameters for the current job
        job_params = parameters_table(strcmp(parameters_table.Job, job_name), :);
        uni_years = job_params.TimeUni;
        uni_fees = job_params.UniCost;
        placement_hours = job_params.PlacementHoursYearly;


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
        for i = 1:length(t)
            loan_balance = loan(i);
            [current_salary, repayment_amount, salary_after_repayments, loan_change, employee_super_contrib] = compute_current_salary(t(i), uni_years, uni_fees, salary_data, employee_super, loan_balance, repayment_threshold, repayment_rate, placement_hours, min_wage_hourly);
            repayments(i) = repayment_amount;
            salary_after_repayments(i) = salary_after_repayments;
            salary(i) = current_salary;
            super_contrib(i) = employee_super_contrib;
        end

        % interpolate and save
        SALARY(:,3+j) = interp1(t,salary,TIME);
        SUPER(:,3+j) = interp1(t,super,TIME);
        
        figure(10); plot(TIME,SUPER(:,3+j)); hold on;
        SUPER_CONTRIB(:,3+j) = interp1(t,super_contrib,TIME);
        REPAYMENTS(:,3+j) = interp1(t,repayments,TIME);
        JOB(3+j) = {job_name};

        figure(2);
        subplot(2,2,j);
        police_super = SUPER(:,2);
        fire_super = SUPER(:,3);
        super_ratio1 = SUPER(:,3+j)./police_super;
        super_ratio2 = SUPER(:,3+j)./fire_super;
        plot(TIME,super_ratio1);
        hold on;
        %plot(TIME,super_ratio2);
        xlabel('Time (years)');
        grid on;

    end
end



%%
figure(10); clf;
plot(TIME,SUPER);



%% plot superannuation contributions

employee_super = [3,7.5,6,3,3,3,3];
employer_super = [3,10.184,9,3,3,3,3];

figure(10); clf;

CONTRIB_END = [];
SUPER_END = [];

for j = 1:7
    
    govt_contrib = zeros(size(TIME));
    ESCT_TAX_RATE = zeros(size(TIME));
    
    % employee superannuation contribution
    employee_super_contrib = SALARY(:,j)*employee_super(j)/100;
    cum_employee_super = cumtrapz(TIME,employee_super_contrib);
    for i = 1:length(TIME)
        if ismember(j,[1,4,5,6,7])
            if employee_super_contrib(i) > 1042
                govt_contrib(i) = 541;
            else
                govt_contrib(i) = 0.5*employee_super_contrib(i);
            end
        else
            govt_contrib(i) = 0;
        end
    end
    cum_govt_contrib = cumtrapz(TIME,govt_contrib)';
    
    % employer superannuation contribution
    employer_super_contrib = SALARY(:,j)*employer_super(j)/100;
    for i = 1:length(TIME)
        esct_tax_rate = esct_calc(SALARY(i,j));
        ESCT_TAX_RATE(i) = esct_tax_rate;
    end
    employer_super_contrib_posttax = (1-esct_tax_rate)*employer_super_contrib;
    cum_employer_super = cumtrapz(TIME, employer_super_contrib_posttax); 
    
    figure(1); subplot(3,1,1);
    plot(TIME,cum_employee_super); hold on;
    
    subplot(3,1,2);
    plot(TIME,cum_employer_super); hold on;
    
    subplot(3,1,3);
    plot(TIME,cum_govt_contrib); hold on;
    
    total_super_contribs = cum_employee_super + cum_employer_super + cum_govt_contrib;
    
    figure(10); subplot(1,2,1);
    plot(TIME,total_super_contribs); hold on;
    xlim(tplot);
    
    subplot(1,2,2);
    plot(TIME,SUPER(:,j)); hold on;
    xlim(tplot);

    CONTRIB_END(j) = total_super_contribs(end);
    SUPER_END(j) = SUPER(end,j);
end













