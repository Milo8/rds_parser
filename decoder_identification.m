% Decoder Identification 
% DI idicates diffrent operating modes to switch individual decoders
% 3.2.1.5,  Table 9

function DId = decoder_identification(DId,DI)
  
   if DI(1) == 0
       DId{1} = 'Mono';
   else 
       DId{1} = 'Stereo';
   end
   
   if DI(2) == 0
       DId{2} = 'Not Artificial Head';
   else
       DId{2} = 'Artificial Head';
   end
   
   if DI(3) == 0
       DId{3} = 'Not Compressed';
   else
       DId{3} = 'Compressed';
   end

   if DI(4) == 0
       DId{4} = 'Static PTY';
   else
       DId{4} = 'Dynamic PTY ';
   end
end
