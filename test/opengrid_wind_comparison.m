function summary = opengrid_wind_comparison(outputDir)
%OPENGRID_WIND_COMPARISON Compare AC power flow at several wind outputs.
% Outputs CSV tables and three plots to outputDir.

    define_constants;
    if nargin < 1 || isempty(outputDir)
        outputDir = fullfile(pwd, 'opengrid_results');
    end
    if ~exist(outputDir, 'dir')
        mkdir(outputDir);
    end

    windLevels = [0, 18, 36, 54];   % MW injected at Bus 5
    options = mpoption('verbose', 0, 'out.all', 0);
    nCases = numel(windLevels);

    losses = nan(nCases, 1);
    minVoltage = nan(nCases, 1);
    maxVoltage = nan(nCases, 1);
    maxLoading = nan(nCases, 1);
    bus5NetLoad = nan(nCases, 1);
    generator2MW = nan(nCases, 1);
    slackMW = nan(nCases, 1);
    busRows = [];
    branchRows = [];
    voltageByCase = [];
    busNumbers = [];

    for i = 1:nCases
        windMW = windLevels(i);
        mpc = opengrid_build_case(windMW);
        [pf, success] = runpf(mpc, options);
        if ~success
            error('Power flow failed for %.1f MW of wind output.', windMW);
        end

        rating = pf.branch(:, RATE_A);
        flowFromMVA = hypot(pf.branch(:, PF), pf.branch(:, QF));
        flowToMVA = hypot(pf.branch(:, PT), pf.branch(:, QT));
        branchMVA = max(flowFromMVA, flowToMVA);
        loadingPct = nan(size(rating));
        hasRating = (rating > 0) & (pf.branch(:, BR_STATUS) > 0);
        loadingPct(hasRating) = 100 * branchMVA(hasRating) ./ rating(hasRating);

        % Total active network loss = active generation - specified net demand.
        onlineGen = pf.gen(:, GEN_STATUS) > 0;
        losses(i) = sum(pf.gen(onlineGen, PG)) - sum(pf.bus(:, PD));
        minVoltage(i) = min(pf.bus(:, VM));
        maxVoltage(i) = max(pf.bus(:, VM));
        if any(hasRating)
            maxLoading(i) = max(loadingPct(hasRating));
        end

        bus5Row = pf.bus(:, BUS_I) == 5;
        gen2Row = pf.gen(:, GEN_BUS) == 2 & pf.gen(:, GEN_STATUS) > 0;
        slackRow = pf.gen(:, GEN_BUS) == 1 & pf.gen(:, GEN_STATUS) > 0;
        bus5NetLoad(i) = pf.bus(bus5Row, PD);
        generator2MW(i) = sum(pf.gen(gen2Row, PG));
        slackMW(i) = sum(pf.gen(slackRow, PG));

        nBus = size(pf.bus, 1);
        nLine = size(pf.branch, 1);
        busRows = [busRows; ...
            [repmat(windMW, nBus, 1), pf.bus(:, BUS_I), ...
             pf.bus(:, VM), pf.bus(:, VA)]]; %#ok<AGROW>
        branchRows = [branchRows; ...
            [repmat(windMW, nLine, 1), pf.branch(:, F_BUS), ...
             pf.branch(:, T_BUS), branchMVA, rating, loadingPct]]; %#ok<AGROW>

        if i == 1
            busNumbers = pf.bus(:, BUS_I);
            voltageByCase = nan(nBus, nCases);
        end
        voltageByCase(:, i) = pf.bus(:, VM);
    end

    summary = table(windLevels(:), bus5NetLoad, generator2MW, slackMW, ...
        losses, minVoltage, maxVoltage, maxLoading, ...
        'VariableNames', {'WindMW', 'Bus5NetLoadMW', 'Gen2MW', ...
        'SlackMW', 'LossMW', 'MinVoltagePU', 'MaxVoltagePU', ...
        'MaxBranchLoadingPct'});
    busTable = array2table(busRows, 'VariableNames', ...
        {'WindMW', 'Bus', 'VoltagePU', 'AngleDeg'});
    branchTable = array2table(branchRows, 'VariableNames', ...
        {'WindMW', 'FromBus', 'ToBus', 'FlowMVA', 'RatingMVA', 'LoadingPct'});

    writetable(summary, fullfile(outputDir, 'wind_summary.csv'));
    writetable(busTable, fullfile(outputDir, 'wind_bus_results.csv'));
    writetable(branchTable, fullfile(outputDir, 'wind_branch_results.csv'));

    figureHandle = figure('Visible', 'off');
    plot(busNumbers, voltageByCase, '-o', 'LineWidth', 1.4);
    xlabel('Bus number');
    ylabel('Voltage magnitude (p.u.)');
    title('IEEE 9-bus voltages at different wind outputs');
    legend(arrayfun(@(x) sprintf('%g MW', x), windLevels, ...
        'UniformOutput', false), 'Location', 'best');
    grid on;
    saveas(figureHandle, fullfile(outputDir, 'bus_voltage_comparison.png'));
    close(figureHandle);

    figureHandle = figure('Visible', 'off');
    plot(windLevels, losses, '-o', 'LineWidth', 1.4);
    xlabel('Wind injection at Bus 5 (MW)');
    ylabel('Total real power losses (MW)');
    title('System losses versus wind output');
    grid on;
    saveas(figureHandle, fullfile(outputDir, 'system_losses.png'));
    close(figureHandle);

    figureHandle = figure('Visible', 'off');
    plot(windLevels, maxLoading, '-o', 'LineWidth', 1.4);
    xlabel('Wind injection at Bus 5 (MW)');
    ylabel('Maximum branch loading (% of rating A)');
    title('Maximum branch loading versus wind output');
    grid on;
    saveas(figureHandle, fullfile(outputDir, 'max_branch_loading.png'));
    close(figureHandle);

    disp('Wind comparison complete:');
    disp(summary);
end
