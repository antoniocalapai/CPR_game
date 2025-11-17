function codecCode = MW_getCodecCode(codecList, codecName)
% function codecCode = MW_getCodecCode(codecList, codecName)
%
% This function returns the code of a codec by given the name of codec
% When the codex dosn't exist it returns 0
%
% rbrockhausen@dpz.eu, Nov 2019


% if (not(strcmp({codecList.name}, ['STIM_' eventList(i).data{stimCX}.name '_onScreen'])))
%
% else
%
% end
%
%
%  codecID(length(codecID)+1) = struct('code', max([codecID.code])+1, 'name', ['STIM_' eventList(i).data{stimCX}.name '_onScreen']);
codecCode = codecList(strcmp({codecList.name}, codecName)).code;

end