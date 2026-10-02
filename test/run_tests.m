function run_tests()
% RUN_TESTS  MATLAB/GNU Octave basic checks; execute after MATPOWER setup.
    root = fileparts(fileparts(mfilename('fullpath')));
    addpath(fullfile(root,'src'));
    assert(exist('runpf','file') ~= 0, 'MATPOWER is required.');
    define_constants;
    c = ogp_config();
    base = loadcase('case9');
    assert(size(base.bus,1) == 9);
    assert(size(base.gen,1) == 3);
    assert(size(base.branch,1) == 9);
    assert(abs(sum(base.bus(:,PD))-315) < 1e-9);
    [wind, info] = ogp_wind_case(base,c);
    assert(abs(info.originalPhysicalDemandMW-315) < 1e-9);
    assert(abs(sum(wind.bus(:,PD))-261) < 1e-9);
    assert(abs(sum(wind.gen(:,PG))-sum(base.gen(:,PG))+54) < 1e-9);
    bus2 = find(wind.gen(:,GEN_BUS) == 2);
    assert(abs(wind.gen(bus2,PG)-109) < 1e-9);
    [n,~,~] = ogp_islands(base);
    assert(n == 1);
    for k = [1 4 7] % isolated generator-bus radial connection
        copy = base;
        copy.branch(k,BR_STATUS) = 0;
        [n,~,members] = ogp_islands(copy);
        assert(n == 2 && numel(members) == 2);
    end
    [br, ba] = ogp_solve(base,c);
    [wr, wa] = ogp_solve(wind,c);
    assert(br.success && wr.success);
    assert(abs(ba.balance_residual_mw) < 1e-3);
    assert(abs(wa.balance_residual_mw) < 1e-3);
    assert(abs(ba.net_demand_mw-315) < 1e-8);
    assert(abs(wa.net_demand_mw-261) < 1e-8);
    assert(all(isfinite(ba.vm)) && all(isfinite(wa.vm)));
    assert(all(ba.loading(ba.monitored) >= 0));
    bn = ogp_n1(base,c);
    wn = ogp_n1(wind,c);
    assert(numel(bn) == 9 && numel(wn) == 9);
    for k = [1 4 7]
        assert(strcmp(bn(k).status,'ISLAND'));
        assert(strcmp(wn(k).status,'ISLAND'));
    end
    assert(all([bn.branch_id] == 1:9));
    cmp = ogp_compare_n1(bn,wn,c);
    assert(numel(cmp) == 9);
    assert(~cmp(1).wind_effect_assessable); % island: no misleading numeric delta
    for i = 1:numel(bn)
        assert(~isempty(bn(i).status) && ~isempty(wn(i).status));
    end
    addpath(fullfile(root,'simulink'));
    dm = ogp_dynamic_metrics((0:0.1:0.5)', [1;0.8;0.9;1;1;1], ...
        [60;59.9;59.95;60;60;60], [0 0;1 3;2 5;1 2;1 1;0 0], 0.2);
    assert(abs(dm.minimum_voltage_pu-0.8) < 1e-12);
    assert(abs(dm.minimum_frequency_hz-59.9) < 1e-12);
    assert(abs(dm.max_rotor_angle_spread_deg-3) < 1e-12);
    fprintf('PASS: case structure, 54 MW dispatch, topology, power balances, N-1, comparison and telemetry helper.\n');
end
