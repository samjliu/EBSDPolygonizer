function [onInVq,locInVcs,members] = isonboundary(vcs,vq,tolerance)
    % ISONBOUNDARY  check whether each vertices on the boundary
    % spcifed by VQ, MQ by 2 matrix for its x and y coordinate in
    % colume 1 and 2 respectively, are on the boundary of VCS
    % ONINVQ are indices in VQ that are on th boundaries but not
    % overlapped with the boudarny vertices; LOCINVCS are the
    % location of the points on the boundary VCS, that is, it will
    % be between locInVcs and locInVcs+1. 
    % MEMBERS are an logical array whether the points on VQ  with the 
    % Check if there are overlapped vertices between the two
%     if nargin<3
%         tolerance = 5;
%     end
    members = ismembertol(vq, vcs, tolerance, 'ByRows', true, 'DataScale', 1);
    notmembers = ~members;
    vqfiltered = vq(notmembers,:);
    indsfiltered = find(notmembers);
    if ~isempty(vqfiltered)
        vcs1 = vcs;
        vcs2 = vertcat(vcs(2:end,:), vcs1(1,:));
        tf = ebsd.map.isInBetween(vcs1, vcs2, vqfiltered, tolerance);
        [onInVqFiltered, locInVcs] = find(tf);
        onInVq = indsfiltered(onInVqFiltered);
    else
        onInVq = [];
        locInVcs = [];
    end
end