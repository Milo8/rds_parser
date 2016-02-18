% Calculates the syndrome of a data chunk
%
% (c) 2001 Lieven Hollevoet, picmicro@hollie.tk

% Re-use of this code is hereby permitted, as long as
% my name and e-mail address are mentioned in the new
% version.

function resultaat = syndrome(loper, data, check)
resultaat = [0 0 0 0 0 0 0 0 0 0];
chunk = data(loper: loper+25);
for bit_check = 1:26
   if (chunk(bit_check))
      resultaat = xor(resultaat, check(bit_check,:));
   end
end




