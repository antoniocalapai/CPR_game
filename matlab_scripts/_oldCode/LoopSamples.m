%for i = 1:10
    i = 4;
    
    onset = target_time(i);
    offset = target_time(i+1);
    sampleLenght = round((offset - onset)/1000);
    
    if sampleLenght > 2000
    disp([(i), sampleLenght])    
        J = joy_dir(joy_dir_time < offset & joy_dir_time > onset);
        T = target(i);
        
        difference = 180 - abs(abs(double(J) - T) -180);
        
        plot(difference(1:2000))
        hold on
    end
%end
hold off