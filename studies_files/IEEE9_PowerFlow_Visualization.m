function summary = IEEE9_PowerFlow_Visualization(bus, branch, studyName, outputFolder)
% IEEE9_POWERFLOW_VISUALIZATION Visualize IEEE 9-bus load-flow results.
%
% INPUT TABLES
% bus must contain these columns (one row for every bus):
%   Bus, Vm_pu, Va_deg, Pg_MW, Qg_MVAr, Pd_MW, Qd_MVAr
%
% branch must contain these columns (one row for every branch):
%   From, To, Pfrom_MW, Qfrom_MVAr, Pto_MW, Qto_MVAr, Rating_MVA
%
% IMPORTANT: Pfrom_MW and Pto_MW are both defined as power injected INTO
% the branch at their respective ends. Therefore, a lossless line with
% 100 MW flowing From --> To would have approximately
% Pfrom_MW = +100 and Pto_MW = -100.  Enter the same sign convention for Q.
%
% EXAMPLE
%   bus = readtable("bus_results.csv");
%   branch = readtable("branch_results.csv");
%   summary = IEEE9_PowerFlow_Visualization( ...
%       bus, branch, "IEEE 9-Bus Base Case", "figures");
%
arguments
    bus table
    branch table
    studyName (1,1) string = "IEEE 9-Bus Power-Flow Results"
    outputFolder (1,1) string = ""
end

requiredBusColumns = ["Bus", "Vm_pu", "Va_deg", "Pg_MW", "Qg_MVAr", ...
    "Pd_MW", "Qd_MVAr"];
requiredBranchColumns = ["From", "To", "Pfrom_MW", "Qfrom_MVAr", ...
    "Pto_MW", "Qto_MVAr", "Rating_MVA"];
mustHaveColumns(bus, requiredBusColumns, "bus");
mustHaveColumns(branch, requiredBranchColumns, "branch");

bus = sortrows(bus, "Bus");
assert(isequal(bus.Bus(:), (1:9)'), ...
    "The bus table must include exactly one row for buses 1 through 9.");
assert(all(branch.Rating_MVA > 0), "Every branch Rating_MVA must be positive.");

% Derived line quantities.  Pto/Qto use the branch-injection convention
% documented above, so Pfrom + Pto is the real-power loss in the branch.
branch.Sfrom_MVA = hypot(branch.Pfrom_MW, branch.Qfrom_MVAr);
branch.Sto_MVA = hypot(branch.Pto_MW, branch.Qto_MVAr);
branch.Flow_MVA = max(branch.Sfrom_MVA, branch.Sto_MVA);
branch.Loading_pct = 100 * branch.Flow_MVA ./ branch.Rating_MVA;
branch.Loss_MW = branch.Pfrom_MW + branch.Pto_MW;
branch.Loss_MVAr = branch.Qfrom_MVAr + branch.Qto_MVAr;

% Use this fixed coordinate layout so all IEEE 9-bus plots have the same
% familiar one-line shape and Base/Wind figures can be compared directly.
coords = [ ...
    0.0, 4.0;   % Bus 1
    4.0, 4.0;   % Bus 2
    8.0, 4.0;   % Bus 3
    1.5, 3.0;   % Bus 4
    4.0, 3.0;   % Bus 5
    6.5, 3.0;   % Bus 6
    2.0, 1.2;   % Bus 7
    4.0, 1.2;   % Bus 8
    6.0, 1.2];  % Bus 9

% ------------------- Figure 1: Numerical operating profile ----------------
figProfile = figure("Color", "w", "Name", studyName + " - Profile");
tiledlayout(figProfile, 2, 2, "Padding", "compact", "TileSpacing", "compact");

nexttile
bar(bus.Bus, bus.Vm_pu, 0.65, "FaceColor", [0.00 0.45 0.74]); hold on
yline(0.95, "--r", "0.95 p.u.", "LabelHorizontalAlignment", "left");
yline(1.05, "--r", "1.05 p.u.", "LabelHorizontalAlignment", "left");
ylim([min(0.90, min(bus.Vm_pu)-0.01), max(1.10, max(bus.Vm_pu)+0.01)])
xlim([0.25 9.75]); xticks(1:9); grid on
xlabel("Bus"); ylabel("Voltage magnitude (p.u.)");
title("Bus-voltage profile")

nexttile
stem(bus.Bus, bus.Va_deg, "filled", "Color", [0.85 0.33 0.10], "LineWidth", 1.2);
xlim([0.25 9.75]); xticks(1:9); grid on
xlabel("Bus"); ylabel("Voltage angle (deg)");
title("Bus-voltage angles")

nexttile
bar(bus.Bus, [bus.Pg_MW, -bus.Pd_MW], "grouped");
xlim([0.25 9.75]); xticks(1:9); grid on
xlabel("Bus"); ylabel("Real power (MW)");
legend("Generation", "Load", "Location", "best");
title("Real-power generation and demand")

nexttile
branchName = compose("%d-%d", branch.From, branch.To);
bar(categorical(branchName), branch.Loading_pct, "FaceColor", [0.47 0.67 0.19]); hold on
yline(100, "--r", "Thermal limit", "LabelHorizontalAlignment", "left");
xtickangle(45); grid on
ylabel("Loading (% of MVA rating)");
title("Branch thermal loading")

sgtitle(studyName, "FontWeight", "bold");

% ---------------- Figure 2: IEEE 9-bus one-line result display -----------
figNetwork = figure("Color", "w", "Name", studyName + " - One Line");
ax = axes(figNetwork); hold(ax, "on"); axis(ax, "equal"); axis(ax, "off");
title(ax, studyName + " — One-Line Power-Flow Display", "FontWeight", "bold");

for k = 1:height(branch)
    fromXY = coords(branch.From(k), :);
    toXY = coords(branch.To(k), :);
    [lineColor, lineStyle] = loadingStyle(branch.Loading_pct(k));
    width = 1.5 + 5 * min(branch.Loading_pct(k) / 100, 1);
    plot(ax, [fromXY(1), toXY(1)], [fromXY(2), toXY(2)], ...
        "Color", lineColor, "LineStyle", lineStyle, "LineWidth", width);

    midpoint = (fromXY + toXY) / 2;
    text(ax, midpoint(1), midpoint(2)+0.16, ...
        sprintf("%d-%d: %.1f MVA (%.0f%%)", branch.From(k), branch.To(k), ...
        branch.Flow_MVA(k), branch.Loading_pct(k)), ...
        "HorizontalAlignment", "center", "FontSize", 8, "BackgroundColor", "w");
end

scatter(ax, coords(:,1), coords(:,2), 650, bus.Vm_pu, "filled", ...
    "MarkerEdgeColor", [0.10 0.10 0.10], "LineWidth", 1.1);
colormap(ax, parula); cb = colorbar(ax); cb.Label.String = "Bus voltage (p.u.)";
caxis(ax, [min(0.94, min(bus.Vm_pu)), max(1.06, max(bus.Vm_pu))]);

for k = 1:height(bus)
    busLabel = sprintf("Bus %d\\n%.3f p.u. | %.1f°", ...
        bus.Bus(k), bus.Vm_pu(k), bus.Va_deg(k));
    text(ax, coords(k,1), coords(k,2), busLabel, "HorizontalAlignment", "center", ...
        "VerticalAlignment", "middle", "FontWeight", "bold", "FontSize", 8);
    annotationText = sprintf("G %.0f MW | L %.0f MW", bus.Pg_MW(k), bus.Pd_MW(k));
    text(ax, coords(k,1), coords(k,2)-0.42, annotationText, ...
        "HorizontalAlignment", "center", "FontSize", 7);
end

text(ax, 0.0, 0.25, "Branch color: blue < 80%, orange 80–100%, red > 100%", ...
    "FontSize", 9, "FontWeight", "bold");
xlim(ax, [-0.8 8.8]); ylim(ax, [0.0 4.7]);

% -------------------- Figure 3: losses and balance -----------------------
figLoss = figure("Color", "w", "Name", studyName + " - Losses");
tiledlayout(figLoss, 1, 2, "Padding", "compact", "TileSpacing", "compact");

nexttile
bar(categorical(branchName), branch.Loss_MW, "FaceColor", [0.49 0.18 0.56]);
xtickangle(45); grid on
ylabel("Real-power loss (MW)");
title("Branch real-power losses")

nexttile
totals = [sum(bus.Pg_MW), sum(bus.Pd_MW), sum(branch.Loss_MW)];
bar(categorical(["Generation", "Load", "Calculated losses"]), totals, ...
    "FaceColor", [0.30 0.75 0.93]);
grid on; ylabel("MW");
title(sprintf("System balance error = %.3f MW", totals(1)-totals(2)-totals(3)))

summary = struct;
summary.studyName = studyName;
summary.bus = bus;
summary.branch = branch;
summary.totalGenerationMW = sum(bus.Pg_MW);
summary.totalLoadMW = sum(bus.Pd_MW);
summary.totalLossMW = sum(branch.Loss_MW);
summary.powerBalanceErrorMW = summary.totalGenerationMW - summary.totalLoadMW - summary.totalLossMW;
summary.overloadedBranches = branch(branch.Loading_pct > 100, :);

fprintf("\n%s\n", studyName);
fprintf("  Generation: %.3f MW\n", summary.totalGenerationMW);
fprintf("  Load:       %.3f MW\n", summary.totalLoadMW);
fprintf("  Losses:     %.3f MW\n", summary.totalLossMW);
fprintf("  Balance error: %.3f MW\n", summary.powerBalanceErrorMW);
if isempty(summary.overloadedBranches)
    fprintf("  No branches exceed their MVA rating.\n\n");
else
    fprintf("  WARNING: %d branch(es) exceed their MVA rating.\n\n", ...
        height(summary.overloadedBranches));
end

if strlength(outputFolder) > 0
    if ~isfolder(outputFolder)
        mkdir(outputFolder);
    end
    safeName = regexprep(studyName, "[^A-Za-z0-9_-]", "_");
    exportgraphics(figProfile, fullfile(outputFolder, safeName + "_profile.png"), "Resolution", 300);
    exportgraphics(figNetwork, fullfile(outputFolder, safeName + "_one_line.png"), "Resolution", 300);
    exportgraphics(figLoss, fullfile(outputFolder, safeName + "_losses.png"), "Resolution", 300);
    writetable(branch, fullfile(outputFolder, safeName + "_branch_summary.csv"));
end
end

function mustHaveColumns(T, requiredNames, tableName)
missingNames = requiredNames(~ismember(requiredNames, string(T.Properties.VariableNames)));
assert(isempty(missingNames), "%s is missing columns: %s", tableName, strjoin(missingNames, ", "));
end

function [lineColor, lineStyle] = loadingStyle(loadingPct)
if loadingPct > 100
    lineColor = [0.85 0.10 0.10];
    lineStyle = "-";
elseif loadingPct >= 80
    lineColor = [0.93 0.49 0.19];
    lineStyle = "-";
else
    lineColor = [0.00 0.45 0.74];
    lineStyle = "-";
end
end
