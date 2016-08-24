function [model,f] = EM_GMM(ldata,labels,udata)
%GMM Summary of this function goes here
%   Detailed explanation goes here

%initial
udata(udata(:,4)>50,:)=[];

class = unique(labels);
C = size(class,1);
[N,D] = size(udata);

a = zeros(1,C);
u = zeros(C,D);
pSigma = zeros(D, D, C);
f = zeros(N,C);

temp = 0;
temp2 = 0;
data = [udata;ldata];
maxepoch = 1200;

init_params;

for i = 1:maxepoch;
    %expectation
    calc_prob;
    
    %maximize
    update_a;
    update_u;
    update_pSigma;
end

%output
model = [];
model.u = u;
model.pSigma = pSigma;
model.a = a;
%varargout = {f, model};

    function calc_prob
        %Gaussian posterior probability
        %N(x|pMiu,ppSigma) = 1/((2pi)^(D/2))*(1/(abs(pSigma))^0.5)*exp(-1/2*(x-pMiu)'ppSigma^(-1)*(x-pMiu))
        %data_num = size(data,1);
        %Px = zeros(data_num,C);
        for j = 1:C
            Xshift = udata-repmat(u(j, :), N, 1); %X-pMiu
            inv_pSigma = inv(pSigma(:, :, j));
            tmp = sum((Xshift*inv_pSigma) .* Xshift, 2);
            %tmp = sum((pSigma(:, :, k)/Xshift).* Xshift, 2);
            coef = (2*pi)^(-D/2) * sqrt(det(inv_pSigma));
            %Px(:, k) = coef * exp(-0.5*tmp);
            f(:,j) = coef * exp(-0.5*tmp);
        end
    end

    function init_params
        for j = 1:D
            Xi = ldata(labels==class(j),:);
            u(j,:) = mean(Xi,1);
            pSigma(:,:,j) = cov(Xi);
            a(j) = size(Xi,1)/size(data,1);
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
        for j =1:C
            sum_zik(j,:) = sum(ldata(labels==class(j)));
            Ni(j) = size(labels==class(j),1);
        end
        numerator = diag(1) * temp' * udata + sum_zik;
        
        for j = 1:C
            denominator(j)=temp(j)+Ni(j);
            u(j,:) = numerator(j,:)/denominator(j);
            temp2 = denominator;
        end
    end

    function update_pSigma
        denominator = temp2;
        temp = sum(temp,1);
        for j = 1:C
            Xshift = udata-repmat(u(j, :), N, 1);
            ldatai = ldata(labels==class(j),:);
            Zshift = ldatai-repmat(u(j, :), size(ldatai,1), 1);
            pSigma(:, :, j) = ((Xshift' * (diag(temp(:, j)) * Xshift))+ Zshift'*Zshift)/(denominator(j));
        end
        
%         for kk = 1:K   
%             Xshift = X-repmat(pMiu(kk, :), N, 1);  
%             pSigma(:, :, kk) = (Xshift' * (diag(pGamma(:, kk)) * Xshift)) / Nk(kk);  
%         end  
    end
end

