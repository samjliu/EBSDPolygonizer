function tf = isInBetween(pa, pb, pq, tolerance)
    % Check whehter the point PQ is on the line through points PA
    % and PB and between PA and PB
%     if nargin < 4
%         tolerance = 0.1;
%     end
    tf = false(size(pq,1), size(pa,1));
    for i = 1:size(pa,1)
        y2 = pb(i,2);
        y1 = pa(i,2);
        x2 = pb(i,1);
        x1 = pa(i,1);
        k = (y2 - y1) ./ (x2 - x1);
        b = y1 - k * x1;
        distseg = sqrt((y2 - y1).^2 + (x2-x1).^2);
        if abs(x1-x2)<tolerance && abs(y1-y2)>tolerance
            tf(:,i) = abs(pq(:,1) -x1)<tolerance & pq(:,2) < max(y2,y1) & pq(:,2) > min(y2,y1);
        elseif abs(x1-x2)<tolerance && abs(y1-y2)<tolerance
            warning('Two points are coincident and no line can be determined...')
        else
            dist1 = sqrt((pq(:,2) - y1).^2 + (pq(:,1) - x1).^2);
            dist2 = sqrt((pq(:,2) - y2).^2 + (pq(:,1) - x2).^2);
            distboth = dist1 + dist2;
            tf(:,i) = abs(k .* pq(:,1) + b - pq(:,2))<tolerance & abs(distboth - distseg)<tolerance;
        end 
    end
end