classdef edgevc<handle
    properties
        ID
        x
        y
        vertice 
        iscorner = false;
        edge % l b r t
    end
    
    methods
        function ev = ebsdedgevc(x,y)
            if isvector(x) && isvector(y) && length(x) == length(y)
                for i = 1:length(x)
                    ev(i).x = x(i);
                    ev(i).y = y(i);
                    if ev(i).x == 0 && ev(i).y ~= 0
                        ev(i).edge = 'l';
                    elseif ev(i).y == 0 && ev(i).x ~= 0;
                        ev(i).edge = 'b';
                    end                        
                end
            else
                error('X and Y must be vector of same size')
            end
        end
    end
end