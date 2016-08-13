function [ pred ] = EM_GMM(ldata,label,udata)
%GMM Summary of this function goes here
%   Detailed explanation goes here

%initial
class = unique(label);
C = size(class,1);
N = size(udata,1);
D = size(udata,2);
Lprev = -inf;

a = zeros(class_Size,2);
u = zeros(class_Size,D);
f = 0;

temp = 0;

while error>tor
    %expectation
    f = calc_prob(udata,u,sigma);
    
    %maximize
    update_a;
    update_u;
    update_sigma;
    
    %check convergence
    check_convergence;
end

        model = [];
        model.u = u;
        model.sigma = sigma;
        model.a = a;
        varargout = {f, model};

    function Px = calc_prob(data,u,sigma)
        %Gaussian posterior probability
        %N(x|pMiu,pSigma) = 1/((2pi)^(D/2))*(1/(abs(sigma))^0.5)*exp(-1/2*(x-pMiu)'pSigma^(-1)*(x-pMiu))
        data_num = size(data,1);
        Px = zeros(data_num,C);
        for k = 1:C
            Xshift = data-repmat(u(k, :), data_num, 1); %X-pMiu
            inv_pSigma = inv(sigma(:, :, k));
            %tmp = sum((Xshift*inv_pSigma) .* Xshift, 2);
            tmp = sum((sigma(:, :, k)/Xshift) .* Xshift, 2);
            coef = (2*pi)^(-D/2) * sqrt(det(inv_pSigma));
            Px(:, k) = coef * exp(-0.5*tmp);
        end
    end

    function update_a
        numerator = f .* repmat(a, N, 1); %numerator = ai * fi(xk | u(i), sigma(i))
        denominator = repmat(sum(numerator, 2), 1, C); %denominator = sumj(pi(j) * N(xi | pMiu(j), pSigma(j)))
        probs = numerator./denominator;
        a = sum(probs,1);
    end

    function update_u
        numerator = f .* repmat(a, N, 1); %numerator = ai * fi(xk | u(i), sigma(i))
        denominator = repmat(sum(numerator, 2), 1, C); %denominator = sumj(pi(j) * N(xi | pMiu(j), pSigma(j)))
        temp = sum(numerator./denominator,1);
        sum_zik = zeros(C,D);
        Ni = zeros(C,1)
        for i =1:C
            sum_zik(i,:) = sum(ldate(label==class(i)));
            Ni(i) = size(label==class(i));
        end
        numerator = diag(1) * temp' * udata+sum_zik;
        
        for i = 1:C
            denominator(i)=temp(i)+Ni(i);
            u(i,:) = numerator(i,:)/denominator(i);
        end
    end

    function update_sigma
        for i = 1:C
            Xshift = udata-repmat(u(i, :), N, 1);
            ldatai = ldate(label==class(i));
            Zshift = ldatai-repmat(u(i, :), size(ldatai,1), 1);
            sigma(:, :, i) = ((Xshift' * (diag(temp(:, i)) * Xshift))+ sum(Zshift*Zshift'))/(denominator(i));
        end
    end

    function check_convergence
        L = sum(log(f*a'));
        if L-Lprev < threshold
            break;
        end
        Lprev = L;     
    end
end

