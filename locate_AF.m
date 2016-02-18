% Places AF values in Alternative_frequencies vector
% and number of frequencies in Num_of_AF

function [Alternative_frequencies, i, N] = locate_AF(Alternative_frequencies, afn1 , afn2, i, N)

if afn1 >= 224
    N = afn1 - 224;                      % Number of HVF Alternative Frequencies 
    af1 = 1;
else
    af1 = 87.5 + (afn1 * 0.1);           % VHF Carrier frequency  [Table 10 VHF code table]
end

if afn2 >= 224
    N = afn2 - 224;
    af2 = 1;
else
    af2 = 87.5 + (afn2 * 0.1);
end
    
if isempty(find(Alternative_frequencies == af1))
    Alternative_frequencies(i) = af1;
    i = i+1;
end

if isempty(find(Alternative_frequencies == af2))
    Alternative_frequencies(i) = af2;
    i = i+1;
end
end