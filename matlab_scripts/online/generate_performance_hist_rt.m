%generate performanace histogram
function yStack = generate_performance_hist_rt(trialInfo,timeEarly,timeLate)

InitialDirections = unique(trialInfo(:,2));%iniial directions
countRep = zeros(length(InitialDirections),6);%each output for each initial direction
%countMax = zeros(length(InitialDirections),6);%ma

for i = 1:length(InitialDirections)
    init = InitialDirections(i);%for this particular initial direction
   
    idxCurrentDir = trialInfo(:,2) == init;%index of the current initial direction
    %check how each output is present
    %1. success
    idx1 = trialInfo(:,5) == 1;%success
    countRep(i,1) = sum(idxCurrentDir & idx1);%given direction with success
    
    %2. Incorrect
    idx2 = trialInfo(:,5) == 2;%incorrect
    countRep(i,2) = sum(idxCurrentDir & idx2);%given direction with incorrect
    
    %3. Miss
    idx3 = trialInfo(:,5) == 3;%miss
    countRep(i,3) = sum(idxCurrentDir & idx3);%given direction with miss
    
    %4. Early
    idx4 = trialInfo(:,5) == 4;%early
    countRep(i,4) = sum(idxCurrentDir & idx4);%given direction with early
    
    %5. Successful catch trial
    idx5 = trialInfo(:,5) == 5;%Successful catch trial
    countRep(i,5) = sum(idxCurrentDir & idx5);%given direction with successful catch trial
    
    %6. Failed catch trial
    idx6 = trialInfo(:,5) == 6;%Failed catch trial
    countRep(i,6) = sum(idxCurrentDir & idx6);%given direction with failed catch trial
end
%dirRep = sum(countRep,2);  %frequency of each initial direction

 edges = [-180:10:180];%[floor(min(InitialDirections)/10)*10:10:ceil(max(InitialDirections)/10)*10];%bin edges of the performance distribution
 binCount = zeros(length(edges)-1,6);%bins
for i = 1:length(InitialDirections)%for all initial directions
        for e = 1:length(edges)-1%look in each bin
            leftEdge = edges(e);
            rightEdge = edges(e+1);

                if InitialDirections(i)>= leftEdge && InitialDirections(i) <rightEdge
                    binCount(e,1:end) = binCount(e,1:end) + countRep(i,1:end);
                   
                end
        end
end
binRep = sum(binCount,2);  %toal number of reps in each bin
success_choice = sum(idx1);
incorrect = sum(idx2);
miss = sum(idx3);
early = sum(idx4);
success_catch = sum(idx5);
failed_catch = sum(idx6);
numTrials = length(idx1);
yStack = binCount*100./binRep;%percentage
successRate = round((success_choice + success_catch)*100/numTrials);
correctRate = round((success_choice )*100/(success_choice + incorrect));
close all;
subplot(2,2,[1,2]);
bar(edges(2:end),yStack,'stacked'); hold on; xlabel('Initial Direction'); ylabel('Percent Correct (%)','FontSize',30); xticks(edges); ylim([0 200]);
yline(successRate,'r--','LineWidth',2);text(max(edges)+10, successRate+1 , [num2str(successRate) ' %'], 'FontSize', 30);
yline(correctRate,'g--','LineWidth',3);text(max(edges)+10, correctRate+1 , [num2str(correctRate) ' %'], 'FontSize', 30);
title(['Training Day - Today' ' : Initial Direction = [' num2str(min(edges)) ' , ' num2str(max(edges)) '] , \Delta \Theta = 20 degrees ' ],  'FontSize', 40);
ax = get(gca,'XTickLabel');
set(gca,'XTickLabel',ax, 'FontSize',20, 'FontWeight','bold');
set(gca,'XTickLabelMode','auto');
legend('Successful Choice','Incorrect Choice','Missed Trial','Early Response','Successful Catch Trial','Failed Catch Trial');
set(gcf,'Position',get(0,'Screensize'));

 subplot(2,2,3);
    Responses = [success_choice incorrect miss early success_catch failed_catch];
    labels = {'Successful Choice', 'Incorrect Choice', 'Miss', 'Early Response','Successful CT', 'Failed CT'};
    pie(Responses)%, explode, labels);
    legend(labels,'Location','southwest');  
    %RT histogram
    
%     timeEarly = 200;
%     timeLate = 650;
    idxSuccess = trialInfo(:,5) == 1;
%index of incorrect
idxIncorrect = trialInfo(:,5) == 2;

%combine these two to get the valid reaction times
idxRT = logical(idxSuccess + idxIncorrect);
RT = (trialInfo(idxRT,8)-trialInfo(idxRT,7))/1000;
earlyIdx = RT < timeEarly;%eliminate early respones
lateIdx = RT > timeLate;%eliminate late respones
sortedRT = RT(~earlyIdx & ~lateIdx);%sorted RT after outlier exclusion
%Work on histogram later
medianRT = median(sortedRT);%median RT

subplot(2,2,4), histogram(sortedRT,[0:50:timeLate]); xlabel('Reaction time (ms)','FontSize',20); ylabel('Frequency','FontSize',20);
title(['Median Reaction time = ' num2str(round(medianRT)) ' ms | Bin width = 50 ms' ],'FontSize',25);
xline(medianRT,'g--','LineWidth',2);
xticks([0:50:timeLate]);
ax = get(gca,'XTickLabel');
set(gca,'XTickLabel',ax, 'FontSize',20, 'FontWeight','bold');