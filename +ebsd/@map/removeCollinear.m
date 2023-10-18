function [gone, verticesremained] = removeCollinear(vcs,tol)
    a=vcs(:,1)';
    b=vcs(:,2)';
    before=numel(a);
    after=before+1;
    stayed = 1:size(vcs,1);
    stayed = stayed';
    gone = true(size(stayed));
    while after~=before && numel(a)>3
        before=numel(a);
        X=[a(1:end-1);a(2:end);[a(3:end),a(1)]];
        Y=[b(1:end-1);b(2:end);[b(3:end),b(1)]];
        A=polyarea(X,Y);
        I=[false,abs(A)<tol];
%         if numel(stayed) - numel(find(I)) >= 3
            a(I)=[];
            b(I)=[];
            stayed(I) = [];
%         else            
%             warning('Abort as polygon would have less than 3 vertices if continue')
%         end
        
        after=numel(a);
    end
    gone(stayed) = false;
    verticesremained = [a', b'];
end