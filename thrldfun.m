function dVal = thrldfun(value)

dVal=uint8(0);
for i=1:1:255
   if (value > (i/255) && value < ((i+1)/255) )
        dVal=i;
        break;
   end
end

