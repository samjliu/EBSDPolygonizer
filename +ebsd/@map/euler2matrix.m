function f = euler2matrix(phi1,phi,phi2,unit)
    % Convert three eular angles to a grain orientation matrix
    %
    if nargin < 4
        unit = 'rad';
    end

    switch unit
        case 'deg'
            phi1 = deg2rad(phi1);
            phi = deg2rad(phi);
            phi2 = deg2rad(phi2);
        case 'rad'
    end
    g11 = cos(phi1) .* cos(phi2) - sin(phi1) .* sin(phi2) .* cos(phi);
    g12 = sin(phi1) .* cos(phi2) + cos(phi1) .* sin(phi2) .* cos(phi);
    g13 = sin(phi2) .* sin(phi);
    g21 = -cos(phi1) .* sin(phi2) - sin(phi1) .* cos(phi2) .* cos(phi);
    g22 = -sin(phi1) .* sin(phi2) + cos(phi1) .* cos(phi2) .* cos(phi);
    g23 = cos(phi2) .* sin(phi);
    g31 = sin(phi1) .* sin(phi);
    g32 = -cos(phi1) .* sin(phi);
    g33 = cos(phi);
    f(1,1,:) = g11;
    f(1,2,:) = g12;
    f(1,3,:) = g13;
    f(2,1,:) = g21;
    f(2,2,:) = g22;
    f(2,3,:) = g23;
    f(3,1,:) = g31;
    f(3,2,:) = g32;
    f(3,3,:) = g33;
end