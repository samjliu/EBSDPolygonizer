function smoothgb(emap,para)
    if nargin < 2
        para = {5};
    end
    emap.grains.smoothgb(para);
end