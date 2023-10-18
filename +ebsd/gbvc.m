classdef gbvc<handle
    properties
        ID = 0          % 0 by default, meaning it has not been claimed by any ebsdmap. Once it is claimed, it will get a unique ID
        x
        y
        vertice
        ofgbs
        ofgrains
        history
        active = true;
        isedge = false;
        protected = false
        isnode = false;
    end
    
    methods
        function gv = gbvc(x,y,ID)
            if nargin < 3
                ID = 0;
            end
            gv.x = x;
            gv.y = y;
            gv.ID = ID;
            
        end
        
        function set(gv, PropName, value)
            if isscalar(value) && length(gv)>1
                value = repmat(value, size(gv));
            end
            
            for i = 1:numel(gv)
                gv(i).(PropName) = value(i);
            end
        end
        
%         function set.x(gv,value)
%             if ~gv.isedge
%                 gv.x = value;
%             end
%         end
%         
%         function set.y(gv,value)
%             if ~gv.isedge
%                 gv.y = value;
%             end
%         end
        
        function values = get.vertice(gv)
            values = [gv.x, gv.y];
        end
        
        function clearlog(gv)
            gv.changelog = string;
        end
        
        function disable(gv)
            gv.active = false;
        end
        
        function plot(gv, varargin)
            scatter(vertcat(gv.x), vertcat(gv.y), varargin{:})
        end
        

        
    end
    
    methods(Static)
        
        function gv = batchCreate(x,y,ID)
            %
            if isvector(x) && isvector(y) && length(x) == length(y)
                if isscalar(ID) && ~isscalar(x)
                    ID = zeros(size(x));
                end
                g = cell(length(x),1);
                for i = 1:length(x)
                    g{i} = ebsd.gbvc(x(i),y(i),ID(i));
                end
                gv = vertcat(g{:});
            else
                error('X and Y must be vector of same size')
            end
        end
    end
    
end