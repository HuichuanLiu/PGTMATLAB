function [ varargout ] = EM_GMM(ldata,labels,udata)
%GMM Summary of this function goes here
%   Detailed explanation goes here

%initial
udata(udata(:,4)>100,:)=[];

class = unique(labels);
C = size(class,1);
[N,D] = size(udata);
Lprev = -inf;
threshold = 0.001;
a = zeros(1,C);
u = zeros(C,D);
pSigma = zeros(D, D, C);
f = zeros(N,C);

temp = 0;
temp2 = 0;
data = [udata;ldata];


Ls = zeros(1000);
p = 1;
init_params;

while p<=1000;
    %expectation
    calc_prob;
    
    %maximize
    update_a;
    update_u;
    update_pSigma;
    
    Ls(p)=sum(log(f*a'));
%     check convergence
%     L = sum(log(f*a'));
%     if L-Lprev < threshold
%         break;
%     end
%     Lprev = L;
    p =p+1;
end

plot(1:1000,Ls);

%output
model = [];
model.u = u;
model.pSigma = pSigma;
model.a = a;
varargout = {f, model};

    function calc_prob
        %Gaussian posterior probability
        %N(x|pMiu,ppSigma) = 1/((2pi)^(D/2))*(1/(abs(pSigma))^0.5)*exp(-1/2*(x-pMiu)'ppSigma^(-1)*(x-pMiu))
        %data_num = size(data,1);
        %Px = zeros(data_num,C);
        for i = 1:C
            Xshift = udata-repmat(u(i, :), N, 1); %X-pMiu
            inv_pSigma = inv(pSigma(:, :, i));
            tmp = sum((Xshift*inv_pSigma) .* Xshift, 2);
            %tmp = sum((pSigma(:, :, k)/Xshift).* Xshift, 2);
            coef = (2*pi)^(-D/2) * sqrt(det(inv_pSigma));
            %Px(:, k) = coef * exp(-0.5*tmp);
            f(:,i) = coef * exp(-0.5*tmp);
        end
    end

    function init_params
        for i = 1:D
            Xi = ldata(labels==class(i),:);
            u(i,:) = mean(Xi,1);
            pSigma(:,:,i) = cov(Xi);
            a(i) = size(Xi,1)/size(data,1);
        end
        
    end

    function update_a
        numerator = f .* repmat(a, N, 1); %numerator = ai * fi(xk | u(i), pSigma(i))
        denominator = repmat(sum(numerator, 2), 1, C); %denominator = sumj(pi(j) * N(xi | pMiu(j), ppSigma(j)))
        probs = numerator./denominator;
        a = sum(probs,1);
    end

    function update_u
        numerator = f .* repmat(a, N, 1); %numerator = ai * fi(xk | u(i), pSigma(i))
        denominator = repmat(sum(numerator, 2), 1, C); %denominator = sumj(pi(j) * N(xi | pMiu(j), ppSigma(j)))
        temp = numerator./denominator;
        sum_zik = zeros(C,D);
        
        Ni = zeros(C,1);
        for i =1:C
            sum_zik(i,:) = sum(ldata(labels==class(i)));
            Ni(i) = size(labels==class(i),1);
        end
        numerator = diag(1) * temp' * udata + sum_zik;
        
        for i = 1:C
            denominator(i)=temp(i)+Ni(i);
            u(i,:) = numerator(i,:)/denominator(i);
            temp2 = denominator;
        end
    end

    function update_pSigma
        denominator = temp2;
        temp = sum(temp,1);
        for i = 1:C
            Xshift = udata-repmat(u(i, :), N, 1);
            ldatai = ldata(labels==class(i),:);
            Zshift = ldatai-repmat(u(i, :), size(ldatai,1), 1);
            t = (Xshift' * (diag(temp(:, i)) * Xshift));
            tt = Zshift'*Zshift;
            ttt = denominator(i);
            pSigma(:, :, i) = ((Xshift' * (diag(temp(:, i)) * Xshift))+ Zshift'*Zshift)/(denominator(i));
        end
        
%         for kk = 1:K   
%             Xshift = X-repmat(pMiu(kk, :), N, 1);  
%             pSigma(:, :, kk) = (Xshift' * (diag(pGamma(:, kk)) * Xshift)) / Nk(kk);  
%         end  
    end
end

