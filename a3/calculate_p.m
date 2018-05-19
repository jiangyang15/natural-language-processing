function p = calculate_p(weights, means, cov, data)
M = size(weights, 2);
T = size(data, 1);
D = size(data, 2);
p = zeros(M, T);
for m = 1:M
    for t = 1:T
        b_denom = 0;
        for d = 1:D
            b_denom = b_denom + (data(t,d) - means(m, d))^2 / cov(m, d);
        end
        log_bm = -1/2 * b_denom - D/2 * log(2*pi) - 1/2 * log(prod(cov(m,:)));
        p(m, t) = exp(log(weights(m)) + log_bm);
    end
end
    
end