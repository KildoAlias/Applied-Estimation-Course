% Run Simulation of a EKF localization for landmark based maps and range
% measurements.
function run_simulation(app, root, simulationfile)
    %% initialize simulation data
    % store simulation data in cell array
    fid = fopen([root simulationfile], 'r');
    if fid <= 0
      fprintf('Failed to open simoutput file "%s"\n\n', simulationfile);
      return
    end
    simulation_data = {};
    while 1
        line = fgetl(fid);
        if ~ischar(line)
            break
        end
        simulation_data = [simulation_data(:)' {line}];
    end
    fclose(fid);
    
    mu = [0; 0; 0]; % initial estimate of state
    global R
    sigma = R; % initial covariance matrix
    enc = [0; 0]; % initial wheel-encoder readings

    % number of timesteps in simulation data
    n_timesteps = size(simulation_data, 2);
    
    % odometry parameters
    E_T = 2048; % encoder ticks per wheel evolution
    B= 0.35; % distance between contact points of wheels in m
    R_L = 0.1; % radius of the left wheel in m
    R_R = 0.1; % radius of the right wheel in m

    % import global variables
    global t % global time
    global show_measurements % visualization mode
    global show_ground_truth % visualization mode
    global show_odometry % visualization mode
    global stop_execution % stop execution flag set by app
    stop_execution = 0;
    
    % save simulation statistics
    timesteps = zeros(1, n_timesteps);
    pose_errors = zeros(size(mu, 1), n_timesteps);
    sigmas = zeros(size(sigma(:), 1), n_timesteps);
    odom_plots = gobjects(1 , n_timesteps);
    ground_truth_plots = gobjects(1 , n_timesteps);
    short_term_plots = [];
    total_measurements = 0; % total number of measurements in simulation
    total_outliers = 0; % total number of detected outliers
    total_misassociations = 0; % total number of incorrectly associated measurements

    %% Run Simulation
    for timestep = 1:n_timesteps

        % read data for current timestep
        line = simulation_data{timestep};
        timestep_data = sscanf(line, '%f');

        % save values from previous timestep
        pt = t; % previous time in seconds
        penc = enc; % wheel-encoder information of previous timestep

        % get information from simulationfile
        t = timestep_data(1); % current time in seconds
        odom = timestep_data(2:4); % odometry information
        enc = timestep_data(5:6); % wheel-encoder information
        true_pose = timestep_data(7:9); % ground-truth pose  
        n_measurements = timestep_data(10); % number of observations available
        if (n_measurements > 0) % if observations for current timestep available
            bearings = timestep_data(12:3:end); % bearing of observation
            ranges = timestep_data(13:3:end); % distance to observed landmark
            z = [ranges'; bearings']; % measurements
            association_ground_truth = timestep_data(11:3:end);  % id of observed landmark
        else
            bearings = [];
            ranges = [];
            z = [ranges';bearings'];
            association_ground_truth = [];
        end

        % relative information to last timestep
        delta_t = t - pt; % time difference
        delta_enc = enc - penc; % wheel-encoder difference

        % compute odometry information
        u = calculate_odometry(delta_enc(1), delta_enc(2), E_T, B, R_L, R_R, delta_t, mu);

        % run EKF
        [mu, sigma, measurement_info] = ekf_localization(mu, sigma, u, z, association_ground_truth);
        
        % get measurement statistics from EKF
        outliers = length(find(measurement_info == 2));
        misassociations = length(find(measurement_info == 1));
        total_outliers = total_outliers + outliers;
        total_measurements = total_measurements + n_measurements;
        total_misassociations = total_misassociations + misassociations;

        % compute pose error

        pose_error = true_pose - mu;
        pose_error = mod(pose_error+pi,2*pi)-pi;
        pose_errors(:, timestep) = pose_error;
        
        % store covariance matrix
        sigmas(:, timestep) = sigma(:);
        
        % store time information
        timesteps(timestep) = t;

        %% Plot Simulation
        
        % display simulation time
        title(app.SimulationAxis, sprintf('Simulation Time: %.1f s', round(t, 1)));

        % delete short-term-plots
        for k = 1:length(short_term_plots)
            delete(short_term_plots(k))
        end

        short_term_plots = gobjects(1, 2*n_measurements+1);
        if show_measurements
            % plot measurements
            plot_colors = ['g', 'r', 'y']; % correctly associated measurements: green | incorrectly associated measurements: red | outliers: yellow
            for i = 1:n_measurements
                plot_color = plot_colors(measurement_info(i)+1);
                measurement_endpoint = mu(1:2) +[ranges(i)*cos(mu(3)+bearings(i));ranges(i)*sin(mu(3)+bearings(i))];
                short_term_plots(i) = plot(app.SimulationAxis, measurement_endpoint(1), measurement_endpoint(2), strcat(plot_color,'.'));
                % laser beam plots
                short_term_plots(n_measurements+i) = plot(app.SimulationAxis, mu(1)+[0 ranges(i)*cos(mu(3)+bearings(i))], ...
                                    mu(2)+[0 ranges(i)*sin(mu(3)+bearings(i))], plot_color);
            end
        end

        % plot robot location: odometry information blue | EKF estimation red |
        % ground truth green
        if show_ground_truth
            odom_plots(timestep) = plot(app.SimulationAxis, true_pose(1), true_pose(2), 'kx');
        else
            for k = 1:length(odom_plots)
            delete(odom_plots(k))
            end
        end
        if show_odometry
            ground_truth_plots(timestep) = plot(app.SimulationAxis, odom(1), odom(2), 'bx');
        else
            for k = 1:length(ground_truth_plots)
            delete(ground_truth_plots(k))
            end
        end
        
        % plot uncertainty ellipse around predicted location
        uncertainty_ellipse = get_uncertainty_ellipse(mu, sigma);
        short_term_plots(end) = plot(app.SimulationAxis, uncertainty_ellipse(1,:), uncertainty_ellipse(2,:), 'g', 'LineWidth', 3);
        
        maet = mean(abs(pose_errors(3,:))); %%%%%%
        maex = mean(abs(pose_errors(1,:)));  %%%%%
        maey = mean(abs(pose_errors(2,:)));  %%%%%
        
        
        % update fields for estimated pose and error
        app.xField.Value = mu(1);
        app.yField.Value = mu(2);
        app.thetaField.Value = round(mu(3) / (2*pi) * 360);
        app.Error_x_Field.Value = maex;
        app.Error_y_Field.Value = maey;
        app.Error_theta_Field.Value = (maet / (2*pi) * 360);
        
        % close-up plot
        cla(app.CloseUpAxis)
        % plot ellipse
        plot(app.CloseUpAxis, uncertainty_ellipse(1,:), uncertainty_ellipse(2,:), 'g', 'LineWidth', 3);        
        hold (app.CloseUpAxis, 'on');
        x = true_pose(1); % ground truth position x
        y = true_pose(2); % ground truth position y
        axis(app.CloseUpAxis, [x-0.5 x+0.5 y-0.5 y+0.5]) % display 0.5m in both directions around ground truth
        % plot ground truth
        plot(app.CloseUpAxis, x, y, 'kx', 'MarkerSize', 20);
        % set ticks
        xticks(app.CloseUpAxis, [x-0.5, x-0.25, x, x+0.25, x+0.5]);
        xticklabels(app.CloseUpAxis, [-0.5, -0.25, 0, 0.25, 0.5])
        yticks(app.CloseUpAxis, [y-0.25, y, y+0.25, y+0.5]);
        yticklabels(app.CloseUpAxis, [-0.25, 0, 0.25, 0.5])
        
        % display measurement statistics
        app.MeasurementField.Value = total_measurements;
        app.IncorrectField.Value = total_misassociations;
        app.OutlierField.Value = total_outliers;

        % pause
        pause(0.2);
        
        % stop execution flag set in app -> stop simulation
        if stop_execution
            break;
        end

    end
    
    if stop_execution == 0
        % get error statistics
        mex = mean(pose_errors(1,:));
        mey = mean(pose_errors(2,:));
%         met = mean(pose_errors(3,:) / (2*pi) * 360);
        met = mean(pose_errors(3,:));
        maex = mean(abs(pose_errors(1,:)));
        maey = mean(abs(pose_errors(2,:)));
%         maet = mean(abs(pose_errors(3,:) / (2*pi) * 360));
        maet = mean(abs(pose_errors(3,:)));

        
        % plot errors and covariance matrices
        figure('Name', 'Evolution State Estimation Errors');
        clf;
        subplot(3,1,1);
        plot(timesteps, pose_errors(1,:));
        ylabel('error\_x [m]');
        title(sprintf('error on x, mean error = %.2fm, mean absolute err = %.2fm', mex, maex));
        subplot(3,1,2);
        plot(timesteps, pose_errors(2,:));
        ylabel('error\_y [m]');
        title(sprintf('error on y, mean error = %.2fm, mean absolute err = %.2fm', mey, maey));
        subplot(3,1,3);
        plot(timesteps, pose_errors(3,:) / (2*pi) * 360);
        xlabel('simulation time [s]');
        ylabel('error\_\theta [�]');
        title(sprintf('error on \\theta, mean error = %.2f rad, mean absolute err = %.2f rad ', met, maet));

        figure('Name', 'Evolution State Estimation Covariance Matrix');
        clf;
        subplot(3,1,1);
        plot(timesteps, sigmas(1,:));
        title('\Sigma(1,1)');
        subplot(3,1,2);
        plot(timesteps, sigmas(5,:));
        title('\Sigma(2,2)');
        subplot(3,1,3);
        plot(timesteps, sigmas(9,:));
        title('\Sigma(3,3)');

        % update fields
        app.ErrorLabel.Text = 'Mean Absolute Error';
        app.Error_x_Field.Value = maex;
        app.Error_y_Field.Value = maey;
        app.Error_theta_Field.Value = round(maet);

        % change stop button in app
        app.StopButton.Text = 'End';
        app.PauseButton.Enable = 'off';
        app.DatasetSelector.Enable = 'off';
    end
end
