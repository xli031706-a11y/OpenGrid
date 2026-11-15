function connected = opengrid_is_connected(mpc)
%OPENGRID_IS_CONNECTED Check if all buses remain connected after an outage.
% Uses a simple graph traversal to avoid requiring extra toolboxes.

    define_constants;
    ids = mpc.bus(:, BUS_I);
    n = numel(ids);
    refRows = find(mpc.bus(:, BUS_TYPE) == REF);
    if isempty(refRows)
        connected = false;
        return;
    end

    activeLines = mpc.branch(:, BR_STATUS) > 0;
    edges = mpc.branch(activeLines, [F_BUS, T_BUS]);
    visited = false(n, 1);
    visited(refRows(1)) = true;

    for pass = 1:n
        previous = visited;
        for k = 1:size(edges, 1)
            a = find(ids == edges(k, 1), 1);
            b = find(ids == edges(k, 2), 1);
            if isempty(a) || isempty(b)
                connected = false;
                return;
            end
            if visited(a) || visited(b)
                visited(a) = true;
                visited(b) = true;
            end
        end
        if isequal(visited, previous)
            break;
        end
    end
    connected = all(visited);
end
