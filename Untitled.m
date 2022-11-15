for alpha = 0.3:0.4:0.7   
%      for alpha = 0:0.5:1
    if mod(alpha - 0.3 ,  0.4 ) == 0
        save_index = ceil(3* (alpha - 0.3 ) / 0.4 + 1)
    else
        save_index = 3 * (2 * alpha) + 1
    end
end

