function [forward_set] = cal_forward_set(E, num_j)

    % cal_forward_set - Description
    % ���� ���󼯺�
    % ��� ��ǰ����
    % Syntax: output = myFun(input)

    forward_set = double(zeros(length(E), num_j)); %  ����Ϊ���

    for i = 1:num_j
        count = 1;

        for row = 1:length(E)

            for col = 1:length(E(1, :))

                if E(row, col) == i
                    forward_set(i, count) = row;
                    count = count + 1;
                end

            end

        end

    end

end
