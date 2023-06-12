%maxlloyd_demo
%demonstrate the iterative Max-Lloyd algotithm for attaining the optimal
%non-uniform quantization, given the probability density function of x
%
% (c) by Arie Yeredor, April 2021
% This code can be used for educational purposes only
%

figure(1)
clf

%Define the support and the hi-resolution version of the pdf f(x)
al=-3;
be=3;
dx=0.001;
x=[al:dx:be];
%f(x) is a truncated and normalized Gaussian Mixture (of equi-probable
%components)
f = 1/36*(9-x.^2);
f(abs(x) > 3) = 0;
f=f/(sum(f)*dx);    %nrmalize
maxf=max(f);
%show the resulting pdf
plot(x,f,'linewidth',2)
axis([al be 0 maxf]);
hold on;

px=sum(x.^2.*f)*dx;    %power of x
logpx=log10(px);

%choose representative values, end by clicking outside of the x range
%max 50 points
disp('Input up to 50 Representatives, end by clicking outside x range')
Mmax=4;
a=zeros(1,Mmax);
ha=zeros(1,Mmax);
xas = [-2.25 -0.75 0.75 2.25];
for m=1:Mmax
    %[xa y]=ginput(1);
    xa = xas(m);
    y = f(x == xa);
    if xa<al || xa>be, break; end
    a(m)=xa;
    ha(m)=plot([xa xa],[0 0.05*maxf],'k','linewidth',2);
end
M=Mmax;
%a=a(1:M);
%ha=ha(1:M);b
[a ix]=sort(a);
ha=ha(ix);

%calculate the implied borders
b=[al 0.5*(a(1:M-1)+a(2:M)) be];
hb=zeros(1,M);
pqvec=zeros(1,M);
for m=1:M
    ix=find(x>b(m) & x<=b(m+1));
    hb(m)=patch([x(ix) x(ix(end)) x(ix([1 1]))],[f(ix) 0 0 f(ix(1))],[m/M 1 1-(m/M)],'FaceAlpha',0.4);
    pqvec(m)=sum((x(ix)-a(m)).^2.*f(ix));
end
it=0;
pq=sum(pqvec)*dx;
title(['M=' num2str(M) ', iteration=' num2str(it) ', QSNR=' sprintf('%5.3f',10*(logpx-log10(pq))) '[dB]'])

manual=true;
disp('Click out of x range below max y to proceed step by step, in range to stop')
disp('Or click above max y outside the x range to run free')
for it=1:250
    if manual
        [xa ya]=ginput(1);
        if xa>=al && xa<=be, break; end
        if ya>maxf, manual=false; end
    end
    %recalculate optimal representatives
    for m=1:M;
        ix=find(x>b(m) & x<=b(m+1));
        a(m)=sum(x(ix).*f(ix))/sum(f(ix));  %conditional mean
        set(ha(m),'xdata',[a(m) a(m)]);
        pqvec(m)=sum((x(ix)-a(m)).^2.*f(ix));
    end
    pq=sum(pqvec)*dx;
    %show iteration count and QSNR results
    title(['M=' num2str(M) ', iteration=' num2str(it) 'a, QSNR=' sprintf('%5.3f',10*(logpx-log10(pq))) '[dB]'])

    if manual
        [xa ya]=ginput(1);
        if xa>=al && xa<=be, break; end
        if ya>maxf, manual=false; end
    end
    if xa>=al && xa<=be, break; end 
    %recalculate borders
    b=[al 0.5*(a(1:M-1)+a(2:M)) be];
    for m=1:M
        ix=find(x>b(m) & x<=b(m+1));
        set(hb(m),'xdata',[x(ix) x(ix(end)) x(ix([1 1]))],'ydata',[f(ix) 0 0 f(ix(1))]);    
        pqvec(m)=sum((x(ix)-a(m)).^2.*f(ix));
    end
    pq=sum(pqvec)*dx;
    %show iteration count and QSNR results
    title(['M=' num2str(M) ', iteration=' num2str(it) 'b, QSNR=' sprintf('%5.3f',10*(logpx-log10(pq))) '[dB]'])
    
    drawnow     %necessary for the free run only
end