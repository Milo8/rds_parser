function [] = disp_groups(g)
    c = 0;
    j = 1;
    k = 2;
    for i=1:length(g)
        if(mod(i,2))
            typ = 'A';
        else
            typ = 'B';
        end
        if(c==0)
            fprintf('Liczba grup typu %d%c = %d\n',i-j,typ,g(i));
            c = c + 1;
            j = j + 1;
        else
            fprintf('Liczba grup typu %d%c = %d\n',i-k,typ,g(i));
            c = 0;
            k = k + 1;
        end
    end
end