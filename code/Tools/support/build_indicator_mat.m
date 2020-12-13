function [ Indicator ] = build_indicator_mat( N, Label )
    Indicator = zeros(N);
    for i = 1:N
        for j = 1:N
            if Label(i) == Label(j)
                Indicator(i, j) = 1;  % Label(i)
            end
        end
    end
end

