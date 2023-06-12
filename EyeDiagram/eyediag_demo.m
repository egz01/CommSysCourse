function eyediag_demo
%demonstrate eye diagrams and their sensitivity to the pulse shape
%for raised-cosine pulses.
%
% (c) by Arie Yeredor, May 2015
% This code can be used for educational purposes only
%

global b lev Nb pflag sflag tp p1 pf 
global roll hpt hpf L htr
global db1 db2 soff tvec sampix hpo hpio htoff

hf=figure(1);
clf
set(hf,'position',[50 50 1000 800])

ht=axes('position',[0.05 0.7 0.9 0.25]);
hi=axes('position',[0.55 0.05 0.4 0.6]);
hp=axes('position',[0.2 0.4 0.3 0.25]);
hf=axes('position',[0.2 0.05 0.3 0.25]);

lev=2;
roll=0;
soff=0;
Nb=50;  %number of bits
L=20;   %samples per bit

hr=uicontrol('Style','Slider',...
    'units','normalized',...
    'Min',0,'Max',1,'Value',0,...
    'position',[0.05 0.27 0.12 0.03],...
    'callback',@newrho);
htr=uicontrol('Style','Text',...
    'units','normalized',...
    'position',[0.05 0.23 0.12 0.03],...
    'String',['rolloff: ' num2str(roll)],...
    'fontsize',10);
hop=uicontrol('Style','Pushbutton',...
    'units','normalized',...
    'position',[0.12 0.05 0.05 0.05],...
    'backgroundcolor','g','callback',@pause,...
    'string','pause');
hos=uicontrol('Style','Pushbutton',...
    'units','normalized',...
    'position',[0.05 0.05 0.05 0.05],...
    'backgroundcolor','r','callback',@stop,...
    'string','stop');
uicontrol('Style', 'popup',...
           'String', '  2 levels|  4 levels|  6 levels|  8 levels',...
           'units','normalized',...
           'Position',[0.05 0.53 0.12 0.1],...
           'fontsize',12,...
           'callback',@newlevel); 
hoff=uicontrol('Style','Slider',...
    'units','normalized',...
    'Min',-L/2,'Max',L/2,'Value',0,...
    'position',[0.05 0.45 0.12 0.03],...
    'callback',@newsoff);
htoff=uicontrol('Style','Text',...
    'units','normalized',...
    'position',[0.05 0.4 0.12 0.03],...
    'String',['timing offset: ' num2str(soff/L)],...
    'fontsize',10);


ep=0.00001;
tvec=[0:Nb*L-1]/L+ep;
db1=10; %first displayed bit
db2=40; %first not displayed bit
Ndb=db2-db1;
p1w=100;  %single-pulse computation range
p1dw=6;   %single-pulse display range
X=zeros(Nb,length(tvec));
x=sum(X);
xeye=reshape(x(db1*L+1:db2*L),2*L,Ndb/2);

tp=[-p1w*L:p1w*L-1]/L+ep;
fp=[-p1w*L:p1w*L-1]/(2*p1w*L)*L;
p1=sin(tp*pi)./(tp*pi)...
    .*cos(tp*pi*roll)./(1-(2*roll*tp).^2);
p1=(1-abs(tp/1.1)).*(abs(tp/1.1)<1);
pf=real(fftshift(fft(fftshift(p1))))/L;

axes(ht);
hpX=plot(tvec,X);
hold on
hpx=plot(tvec,x,'linewidth',2);
sampix=[db1:db2]*L+1+soff;
hpo=plot(tvec(sampix),x(sampix),'ro','linewidth',2);
axis([db1 db2 -2 2])
title('timeline')
axes(hp)
hpt=plot(tp,p1,'linewidth',2);
axis([-p1dw p1dw -0.5 1])
title('p(t)')
axes(hf);
hpf=plot(fp,pf,'linewidth',2);
axis([-1 1 -0.1 1.1])
title('P(f)')
axes(hi)
hpi=plot([0:2*L-1]/L,xeye,'b','linewidth',2);
hold on
hpio=plot((L+soff)/L,xeye(L+1+soff,:),'ro','linewidth',2);
axis([0 2-1/L -2 2])
title('Eye diagram')
b=2*floor(rand(Nb,1)*lev)/(lev-1)-1;

pflag=false;
sflag=false;
sigv=0.01;
v=sigv*randn(1,length(tvec));
while 1
    if ~pflag
        b=[b(2:Nb);2*floor(rand*lev)/(lev-1)-1];
        for nb=1:Nb
            sht=tvec-nb;
            p=sin(sht*pi)./(sht*pi)...
                .*cos(sht*pi*roll)./(1-(2*roll*sht).^2);
            p=(1-abs(sht/1.1)).*(abs(sht/1.1)<1);
            X(nb,:)=b(nb)*p;
        end
        x=sum(X)+v;
        v=[v(L+1:end) sigv*randn(1,L)];
        xeye=reshape(x(db1*L+1:db2*L),2*L,Ndb/2);
        
        for nb=1:Nb
            set(hpX(nb),'ydata',X(nb,:));
        end
        set(hpx,'ydata',x);
        set(hpo,'ydata',x(sampix));
        for nb=1:Ndb/2
            set(hpi(nb),'ydata',xeye(:,nb))
            set(hpio(nb),'xdata',(L+soff)/L)
            set(hpio(nb),'ydata',xeye(L+1+soff,nb))
        end
    end
    drawnow limitrate nocallbacks
    if sflag, break, end
end

function newlevel(hObj,value);
global b lev Nb
lev=get(hObj,'value')*2;
b=2*floor(rand(Nb,1)*lev)/(lev-1)-1;

function pause(hObj,value);
global pflag
pflag=~pflag;

function stop(hObj,value);
global sflag
sflag=~sflag;

function newrho(hObj,value);
global tp p1 pf roll hpt hpf L htr
roll=get(hObj,'value');
p1=sin(tp*pi)./(tp*pi)...
    .*cos(tp*pi*roll)./(1-(2*roll*tp).^2);
pf=real(fftshift(fft(fftshift(p1))))/L;
set(hpt,'ydata',p1);
set(hpf,'ydata',pf);
set(htr,'string',['rolloff: ' num2str(roll)])

function newsoff(hObj,value);
global db1 db2 soff L sampix tvec hpo htoff
soff=round(get(hObj,'value'));
sampix=[db1:db2]*L+1+soff;
set(hpo,'xdata',tvec(sampix));
set(htoff,'String',['timing offset: ' num2str(soff/L)]);
