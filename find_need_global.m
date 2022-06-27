function [NeedGlobal] = find_need_global(GlobalSourceRequest)
    count = 1;
    NeedGlobal = cell(1, 1);

    for i = 1:size(GlobalSourceRequest, 1)

        for j = 1:size(GlobalSourceRequest, 2)

            if GlobalSourceRequest(i, j) ~= 0
                NeedGlobal{1, count} = [i, j];
                count = count + 1;
            end

        end

    end

end
