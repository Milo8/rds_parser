
% Parity check matrix
check = [ 1 0 0 0 0 0 0 0 0 0;
   0 1 0 0 0 0 0 0 0 0;
   0 0 1 0 0 0 0 0 0 0;
   0 0 0 1 0 0 0 0 0 0;
   0 0 0 0 1 0 0 0 0 0;
   0 0 0 0 0 1 0 0 0 0;
   0 0 0 0 0 0 1 0 0 0;
   0 0 0 0 0 0 0 1 0 0;
   0 0 0 0 0 0 0 0 1 0;
   0 0 0 0 0 0 0 0 0 1;
   1 0 1 1 0 1 1 1 0 0;
   0 1 0 1 1 0 1 1 1 0;
   0 0 1 0 1 1 0 1 1 1;
   1 0 1 0 0 0 0 1 1 1;
   1 1 1 0 0 1 1 1 1 1;
   1 1 0 0 0 1 0 0 1 1;
   1 1 0 1 0 1 0 1 0 1;
   1 1 0 1 1 1 0 1 1 0;
   0 1 1 0 1 1 1 0 1 1;
   1 0 0 0 0 0 0 0 0 1;
   1 1 1 1 0 1 1 1 0 0;
   0 1 1 1 1 0 1 1 1 0;
   0 0 1 1 1 1 0 1 1 1;
   1 0 1 0 1 0 0 1 1 1;
   1 1 1 0 0 0 1 1 1 1;
   1 1 0 0 0 1 1 0 1 1];
% Load data
  load rds_bits\FM_Radio_RDS1.txt;
  data = FM_Radio_RDS1.';
  clear FM_Radio_RDS1; %data = data(2:2:end);

% data=data(13:end); % TZ test

lengte = (length(data)-130);
disp('Length of the data is (#bits):');
disp(lengte);
disp('Processing data... Please be patient.');

naam = 'xxxxxxxx';
text1 = 'xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx';
text2 = 'xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx';
AF = 0;
% Syndroms
sA =  [1 1 1 1 0 1 1 0 0 0];
sB =  [1 1 1 1 0 1 0 1 0 0];
sCa = [1 0 0 1 0 1 1 1 0 0];
sCb = [1 1 1 1 0 0 1 1 0 0];
sD =  [1 0 0 1 0 1 1 0 0 0];

% Search for syndroms 
% Bit-slip detection (for synchronisation)
loper = 1;
i = 1;
AF = 0;    % Alternative Frequency vector;
N = 0;     % Number of AF;
MJD = 0;
Y = 0;
M = 0;
Day = 0;
Hour = 0;
Minutes = 0;
LocalTimeOffset = 0;
PI = 0;
PTY = 0;
Traffic = 0;
MS = 0;
DI = [0 0 0 0];
Country = 0;
while (loper < lengte)
   resultaat = syndrome(loper, data, check);
   if (resultaat == sA)
      % If you arrive here, loper contains the offset for the 
      % start of block A. So block B should be at position loper+26 -> check it...
      resultaat = syndrome(loper+26, data, check);
      if (resultaat == sB)                          % Block B found
         resultaat = syndrome (loper + 52, data, check);
         if (resultaat == sCa)                      % Block Ca found
            resultaat = syndrome (loper + 78, data, check);
            if (resultaat == sD)                    % Complete group read
               [naam, text1, text2,i,AF,N,Hour,Minutes,LocalTimeOffset,Y,M,Day,PI,PTY,Traffic,MS,DI,Country] = process(loper, data, naam, text1, text2,i,AF,N, ...
                                                                                            Hour,Minutes,LocalTimeOffset,Y,M,Day,PI,PTY,Traffic,MS,DI,Country);                % Verwerk
               loper = loper + 103;                 % increment loper
            end
         elseif (resultaat == sCb)                  % Block Cb
            resultaat = syndrome (loper + 78, data, check);
            if (resultaat == sD)                    % Complete group read
               [naam text1 text2 AF] = process(loper, data, naam, text1, text2,AF);                % Verwerk
               loper = loper + 103;
            end
         end
      end
   end
   loper = loper + 1;
end

