classdef gb<handle
    properties
        ID              % grain ID 
        vertices        % All the points that consists of the boundaries
        misori          % misorientation angle (in degree)
        owners          % string arrays containing grain ID
        gblength        % total length of the grain boundaries
        verticemembers  %
        continuous = true %
        discontinuity = 1;
        segments
        
    end
    
    methods
        function g = gb(graina,grainb)
            % Construct EBSDGB object to represent a grain boundary segment
            % The input arguments GRAINA and GRAINB are both EBSDGRAIN
            % objects
            if nargin == 2
                va = graina.verticemembers;
                vb = grainb.verticemembers;
                belongto_a = ismember(va,vb);
                belongto_b = ismember(vb,va);
                indgb_a = find(belongto_a);
                indgb_b = find(belongto_b);
                if any(belongto_a)
                    if g.isSuccessive(indgb_a)
                        g.verticemembers = va(belongto_a);
                        g.segments{1} = g.verticemembers;
                    elseif g.isSuccessive(indgb_b)
                        g.verticemembers = vb(belongto_b);
                        g.segments{1} = g.verticemembers;
                    else
                        g.continuous = false;
                        inds = indgb_a;
                        breakfrom = vertcat(diff(inds)>1,0);
                        bp = find(breakfrom);
                        g.discontinuity = length(bp)+1;
                        pickpoints = vertcat(0, bp, length(g.verticemembers));
                        for i = 1:pickpoints-1
                            g.segments{i} = g.verticemembers(pickpoints(i)+1:pickpoints(i+1));
                        end
                    end
                    for j = 1:length(g.segments)
                        seg = g.segments{j};
                        set(seg([1,end]), 'isnode', true);
                    end
                    g.owners = {graina.ID, indgb_a; grainb.ID, indgb_b};
                    ori_a = ebsd.map.euler2matrix(graina.meanphi1, graina.meanPHI, graina.meanphi2,'deg');
                    ori_b = ebsd.map.euler2matrix(grainb.meanphi1, grainb.meanPHI, grainb.meanphi2,'deg');
                    g.misori = rad2deg(det(ori_a\ori_b));
                end
            end
        end
        
        function set(gb, PropName, value)
            if isscalar(value) && length(gb)>1
                value = repmat(value, size(gb));
            end
            
            for i = 1:numel(gb)
                gb(i).(PropName) = value(i);
            end
        end
        
        
        function f = get.ID(egb)
            if ~isempty(egb.owners)
                f = strcat(num2str(egb.owners{1,1}),'|', num2str(egb.owners{2,1}));
            else
                f=-1;
            end
        end
        
        function h = plot(egb,varargin)
            hold on
            for i = 1:size(egb,1)
                h(i) = plot(egb(i).vertices(:,1), egb(i).vertices(:,2), varargin{:});
            end
            hold off
            pbaspect([1 1 1]);
            daspect([1 1 1]);
        end
    end
    
    methods(Static)
        function tf = isSuccessive(a)
            % Determines if all the numbers in a given input 1D array are successive
            % integers. 
            % 
            assert((size(a,1)==1 || size(a,2)==1) && isa(a,'double'));
            a = sort(a);
            tf = (abs(max(a)-min(a))+1)==numel(a);
        end
    end
    
end