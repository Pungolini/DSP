function [anomalies] = Anomalies(x, x_predicted)
    anomalies = zeros(1, length(x));
    for n=1:length(anomalies)
        anomalies(n) = abs(x(n)- x_predicted(n));
        % Count number of anomalies
    end
    
end

