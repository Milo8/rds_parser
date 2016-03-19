% Do the actual processing. 
% If you want to en/disable the intermediate output of the name, text1 and text2
% then you can (un)comment the last 5 lines of this file
%
% (c) 2001 Lieven Hollevoet, picmicro@hollie.tk

% Re-use of this code is hereby permitted, as long as
% my name and e-mail address are mentioned in the new
% version.

% FEATURES 
% 1. Alternative frequencies list(AF)   line 66
% 2. Clock Time and date(CT)            line 136
% 3. Decoder Identification and dynamic PTY indicator(PTYI)   lines 105 and 69
% 4. Extended Country Code (ECC)        line 126
% 5. Enhanced Other Networks information(EON)
% 6. Emergency Warning System(EWS)      
% 7. In House application(IH)
% 8. Music Speech switch(MS)            line 77
% 9. Open Data Applications(ODA)        
% 10. Programme Identification(PI)      line 65 
% 11. Programme Item Number(PIN)        line 144
% 12. Programme Service name(PS)        line 102
% 13. Programme TYpe(PTY)               line 69
% 14. Programme TYpe Name(PTYN)         line 196
% 15. Radio Paging(RP) 
% 16. Radio Text(RT)                    line 175
% 17. Traffic Announcement identification(TA)   line 73
% 18. Transparent Data Channels(TDC)    
% 19. Traffic Massage Channel(TMC)
% 20. Traffic Programme Identification(TP)   line 71


function [naam, text1, text2,i,AF,N, Hour, Minutes,LocalTimeOffset,Y,M,D,PI,PTY,Traffic,MS,DI,Country,Groups] = process(loper, data, naam, text1,text2,i,AF,N,Hour, ...
                                                                                             Minutes,LocalTimeOffset,Y,M,D,PI,PTY,Traffic,MS,DI,Country,Groups)
% Fetch data types

blockA = data(loper    : loper+25);
blockB = data(loper+26 : loper+51);
blockC = data(loper+52 : loper+77);
blockD = data(loper+78 : loper+103);

DId = { '' '' '' ''};
% What do we have?
type = blockB(1:5);

% Program Types Annex F , Table F.1
ProgTypes = {'None' 'News' 'Affairs' 'Info' 'Sport' 'Educate' 'Drama' 'Culture' 'Science' 'Varied' 'Pop M' ...
             'Rock M' 'Easy M' 'Light M' 'Classics' 'Other M' 'Weather' 'Finance' 'Children' 'Social' 'Religion' ...
             'Phone In' 'Travel' 'Leisure' 'Jazz' 'Country' 'Nation M' 'Oldies' 'Folk M' 'Document' 'TEST' 'Alarm!'};
         
% TP and TP 3.2.1.3 , Table 8
TrafficApps = {'This programme does not carry traffic announcements nor does it refer,via EON,to a programme That does'...
               'This programme carries EON information about another programme which gives traffic information' ...
               'This programme carries traffic announcements but none are being broadcast at present and may also carry EON information About other traffic announcements'...
               'A traffic announcement is being broadcast on this programme at present'};
Countries = {'DE' ' ' '';'GR' '' '';'MA' 'CZ' 'PL'};
Languages = {'Unknown/Non aplicable' 'Albanian' 'Breton' 'Catalan' 'Croatian' 'Welsh' 'Czech' 'Danish' 'German' 'English' 'Spanish' 'Esperanto' ...
              'Estonian' 'Basque' 'Farosese' 'French' 'Frisian' 'Irish' 'Gaelic' 'Galician' 'Icelandic' 'Italian' 'Lappish' 'Latin' 'Latvian' ...
              'Luxmebourgian' 'Lithuanian' 'Hungarian' 'Maltese' 'Dutch' 'Norwegian' 'Occitan' 'Polish' 'Portuguese' 'Romanian' 'Romanish' 'Serbian' ...
              'Slovak' 'Slovene' 'Finnish' 'Swedish' 'Turkish' 'Flemish' 'Walloon'};
          
if (type(1:4) == [0 0 0 0])         % We have a group 0A or 0B Basic tuning and switching information 
    % Get PI number
    PI = bin2Hex(blockA(1:16));
    % Get PTY code
    PtyCode = vbin2dec([0 0 0 blockB(7:11)]);  % Programme Type
    PTY = ProgTypes{PtyCode+1};
    % Get Traffic program bit
    TP = blockB(6);                            % Traffic programme
    % Get Traffic annucement bit
    TA = blockB(12);                           % Traffic announcment
    TATP = vbin2dec([0 0 0 0 0 0 TP TA]);
    Traffic = TrafficApps{TATP + 1};
    % Get Music/Speech switch bit
    MSSC = blockB(13);                         % Music Speech switch
    if( MSSC == 1)
        MS = 'Music';
    else
        MS = 'Speech';
    end
    
   if type(5) == 0      % Group 0A   
       Groups(1)= Groups(1) + 1;
       % Get alternative frequency number 
       alter_freq_num_1 = vbin2dec(blockC(1:8));
       alter_freq_num_2 = vbin2dec(blockC(9:16));
   
       [AF, i, N ] = locate_AF(AF,alter_freq_num_1, alter_freq_num_2, i, N);
        %disp(AF);
   end
   if type(5) == 1
       Groups(2)= Groups(2) + 1;
   end
   % Get name segment address code
   seg_addr = blockB(15:16);
   % Get the chars
   ascii_1 = blockD(1:8);
   ascii_2 = blockD(9:16);
   
   char_1 = vbin2char(ascii_1);
   char_2 = vbin2char(ascii_2);
   
   % And put'em in the name-string
   if seg_addr == [ 0 0 ]
      naam(1:2) = [char_1 char_2];
      DI(4) = blockB(14);                      % DI - Decoder Identification
   elseif seg_addr == [ 0 1 ]
      naam(3:4) = [char_1 char_2];
      DI(3) = blockB(14);
   elseif seg_addr == [ 1 0 ]
      naam(5:6) = [char_1 char_2];
      DI(2) = blockB(14);
   elseif seg_addr == [ 1 1 ]
      naam(7:8) = [char_1 char_2];
      DI(1) = blockB(14);
   end
   % Decoder Identification 
   DId = decoder_identification(DId, DI);
   
elseif (type(1:4) == [0 0 0 1 ])               % Group 1A and 1B Programme Item Numer and slow labelling codes 
    if type(5) == 0                            % Group 1A 
        Groups(3)= Groups(3) + 1;
        % Get variant code
        variant_code = vbin2dec([0 0 0 0 0 blockC(2:4)]);
        
        if variant_code == 0                   % Paging and Extended Country Code
            CC = vbin2dec([0 0 0 0 blockA(1:4)]);     % Country code 1-F
            ECC = vbin2dec([0 0 0 0 blockC(13:16)]);  % Extended Country Code E0-E4
            Country = Countries{ECC+1,CC};
        elseif variant_code == 1               % TMC identification
            
        elseif variant_code == 2               % Paging identification
            
        elseif variant_code == 3               % Language codes 
            LC = vbin2dec(blockC(9:16));       % Language code
            Language = Languages{LC+1}; 
        elseif variant_code == 7               % The Emergency Warning System
            
        end
        
        % Program Item Number code consists of Day(5 bits), Hour(5 bits),
        % Minute(6 bits)
        
        Day = vbin2dec([0 0 0 blockD(1:5)]);
        Hours = vbin2dec([0 0 0 blockD(6:10)]);
        Minute = vbin2dec([0 0 blockD(11:16)]);
        
        fprintf('Program Item Number\nDay = %d, Hour and Minute = %d:%d\n',Day,Hours,Minute);
    else
            Groups(4)= Groups(4) + 1;
    end
elseif (type(1:4) == [0 0 1 0 ])               % Group 2A or 2B, contains RT
   if(type(5) == 0)                            % Group 2A
   Groups(5)= Groups(5) + 1;
   % Get text segment address code
   text_seg = blockB(13:16);
   % and group A/B flag
   AB_flag = blockB(12);
   
   % Get the chars
   ascii_1 = blockC(1:8);
   ascii_2 = blockC(9:16);
   ascii_3 = blockD(1:8);
   ascii_4 = blockD(9:16);
   
   char_1 = vbin2char(ascii_1);
   char_2 = vbin2char(ascii_2);
   char_3 = vbin2char(ascii_3);
   char_4 = vbin2char(ascii_4);
   
   chars = [char_1 char_2 char_3 char_4];
   
   [text1 text2] = locate_it(chars, text_seg, AB_flag, text1, text2);
   else                 %Group 2B
   Groups(6)= Groups(6) + 1;
   end
elseif (type(1:4) == [0 0 1 1])                     % Group 3A or 3B
    if type(5) == 0                            % Group 3A, Application identification for Open data
        Groups(7)= Groups(7) + 1;
        % Get Application Group Type Code
        AGTC = blockB(12:16);
        
        % Get AID 
        AID = bin2hex(blockD(1:16));
        fprintf('AID=%s\n',AID);
    else
        Groups(8)= Groups(8) + 1;
    end
elseif (type(1:4) == [0 1 0 0])                   % Groupa 4, Clock-time & date or ODA
   if type(5) == 0                              % 4A
    Groups(9)= Groups(9) + 1;
   % Get MJD
   MJD = vbin2dec24([0 0 0 0 0 0 0 blockB(15:16) blockC(1:15)]);   % Modified Julian Day code
  
   % MJD to YYYY:MM:DD conversion method Annex G
   Y = fix((MJD-15078.2)/365.25);
   M =  fix((MJD - 14956.1 - fix((Y*365.25)))/30.6001);
   D = MJD - 14956 - fix((Y*365.25)) - fix((M*30.6001));
   if M == 14 || M == 15
       K = 1;
   else
       K = 0;
   end
   Y = Y+K;
   M = M-1 - (K*12);
   
   % Get Hour, Minutes and Local Time Offset
   Hour = vbin2dec([0 0 0 blockC(16) blockD(1:4)]);
   Minutes = vbin2dec([0 0 blockD(5:10)]);
   LocalTimeOffset = (vbin2dec([0 0 0 blockD(12:16)]))/2;   % Local Time Offset multiplies of half hours within range -12h to 12h 
   else
       Groups(10)= Groups(10) + 1;
   end
    elseif type(1:4) == [0 1 0 1]             % Group 5A, Transparent Data Channels or ODA
        if type(5) == 0
            Groups(11)= Groups(11) + 1;
        else
            Groups(12)= Groups(11) + 1;
        end
    elseif type(1:4) == [0 1 1 0]             % Groups 6, In-House application or ODA
        if type(5) == 0
            Groups(13)= Groups(13) + 1;
        else
            Groups(14)= Groups(14) + 1;
        end
    elseif type(1:4) == [0 1 1 1]            % Groups 7, Radio Paging or ODA 
        if type(5) == 0
            Groups(15)= Groups(15) + 1;
        else
            Groups(16)= Groups(16) + 1;
        end
    elseif type(1:4) == [1 0 0 0]            % Groups 8, Open Data Application , TMC(Traffic Message Channel)
        if type(5) == 0
            Groups(17)= Groups(17) + 1;
        else
            Groups(18)= Groups(18) + 1;
        end
    elseif type(1:4) == [1 0 0 1]            % Groups 9, Emergency warning systems or ODA
        if type(5) == 0
            Groups(19)= Groups(19) + 1;
        else
            Groups(20)= Groups(20) + 1;
        end
elseif type(1:4) == [1 0 1 0 ]                     % Group 10A, Programme Type Name
    if type(5) == 0
        Groups(21)= Groups(21) + 1;
    % Get A/B flag, changed when new PTYN is being broadcasted
    ab_flag = blockB(12);
    % Get PTYN segment address
    prev_ab_flag; 
    ptyn_seg = blockB(13:15);
    % Get c bit
    c = blockB(16);
    ascii_1 = blockC(1:8);
    ascii_2 = blockC(9:16);
    ascii_3 = blockD(1:8);
    ascii_4 = blockD(9:16);
    
    char_1 = vbin2char(ascii_1);
    char_2 = vbin2char(ascii_2);
    char_3 = vbin2char(ascii_3);
    char_4 = vbin2char(ascii_4);
    
    chars = [char_1 char_2 char_3 char_4];
    
    PTYN = locate_ptyn(PTYN, chars, prev_ab_flag, ab_flag, ptyn_seg, c);
    fprintf('PTYN=%s',PTYN);
    else
        Groups(22)= Groups(22) + 1;
    end
    elseif type(1:4) == [1 0 1 1]            % Groups 11, Open Data Application
        if type(5) == 0
            Groups(23)= Groups(23) + 1;
        else
            Groups(24)= Groups(24) + 1;
        end
    elseif type(1:4) ==[1 1 0 0]            % Groups 12, Open Data Application
        if type(5) == 0
            Groups(25)= Groups(25) + 1;
        else
            Groups(26)= Groups(26) + 1;
        end
    elseif type(1:4) == [1 1 0 1]            % Groups 13, Enhanced Radio Paging or ODA
        if type(5) == 0
            Groups(27)= Groups(27) + 1;
        else
            Groups(28)= Groups(28) + 1;
        end
    elseif type(1:4) == [1 1 1 0]            % Groups 14, Enhanced Other Networks information
        if type(1:4) ==0
            Groups(26) = Groups(29) + 1;
        else
            Groups(30)= Groups(30) + 1;
        end
    elseif type == [1 1 1 1 1]              % Group 15B, Fast basic tuning and switching information
        Groups(32)= Groups(32) + 1;
end  

zender = naam;

fprintf('.');
fprintf('\n');
disp(zender);
disp(text1);
disp(text2);
fprintf('Number of Alternative Frequencies : %d\n AF =',N);
disp(AF);
fprintf('Clock-time [HH:MM UTC +/- Local time offset] = %d:%d UTC + %dh\n',Hour,Minutes,LocalTimeOffset);
fprintf('Date [YYYY.MM.DD] = %d.%d.%d\n',1900+Y,M,D);
fprintf('PI number = %s\n', PI);
fprintf('Programme Type = %s\n',PTY);
fprintf('TP/TA = %s\n',Traffic);
fprintf('Music/Speech switch = %s\n',MS);
fprintf('Decoder Identification = %s, %s, %s, %s\n',DId{1},DId{2},DId{3},DId{4});
fprintf('Country = %d\n', Country);

end
   