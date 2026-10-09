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
