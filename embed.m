function [block,a,k,count]=embed(g,a,k,F,totalbits,count,len)

if g>=64;
    bits=6;
    s=192;
    h=32;
elseif g<64 & g>=32;
    bits=5;
    s=224;
    h=16;
elseif g<32 & g>=16;
    bits=4;
    s=240;
    h=8;
elseif g<16
    bits=3;
    s=248;
    h=4;
end
l=bits;

F1=F(k);

coeff=bitand(g,s);
for i=1:l;

    if bitand(F1,a)==a;
        coeff= bitor(coeff,h);
    end
    count=count+1;
    
    a=a/2;
    h=h/2;
    if a<1;
        k=k+1;
       
        a=128;
        if k>len;
            break;
        end
         F1=F(k);
    end
    if count>totalbits;
        break;
    end
end

block=coeff;
