#!/usr/bin/bash
printf "Welcome to A.T.O.M Robotics Lab \n"
#echo -e $(cat /home/pi/ros_workspaces/message.txt)
#CPU_FREQ= /proc/cpuinfo

echo "The GPU temp: $(vcgencmd measure_temp | grep  -o -E '[[:digit:]].*')"
gpu_temp="$(vcgencmd measure_temp | grep  -o -E '[[:digit:]].*')"
printf "The GPU temp: %s\n" "$gpu_temp"
echo "The voltage: $(vcgencmd measure_volts)"
printf "THE VOLTAGE IS:$(vcgencmd measure_volts)\n"
echo "The I.P Address : $(hostname -I | awk '{print $1}')"
#echo $(cat $CPU_FREQ)

cat << "EOF"

=                                 
                                  =--:::::=                             
                                =--=      =:                            
                               :=:          :                           
                   ***        -=             :                          
              =:==**#**==    -=               :                         
             -:    ***    ==-=:               :                         
            --             ==: ====            =                        
            --             ==      ===     ====-=====-***              
            ==            :==      =:-:--:=====-:====**#**---=          
             -=           =========     =:=    :=     ***  =-==:        
              ==       ==:=:              ::= ==            :==-       
               -=  ====  -=    :++++++++:   :::=            ====       
                -=-      ==  ==++++++++++=     :-=           -===       
             === ==-    ==:   :----------:     ::=-=       =====        
           ==      -=:  :=:   -:-==--==-::     :=  :-    =-==:          
         =:         =-=:-==   -:-==--==-:-     -     -::===:            
        :=            =====    :--------=      -   =:===-               
       ==               -==-   =:------:=     :-:-==-: ==               
       ==               -=:-=-=  ======   ==:-==-:=     :==             
        :-:             :==  :==:    =:--==-::-          :=             
          :---::====  ==:=-=::-======-:==    -=           ==            
             ==::--------==-:::=  =-==:=    =-            ===           
                         ===         =-===-===           ====           
                         :=-             :-====-:======:-===            
                          ==:             -- =:-=========-:             
                          ====           --                             
                           :==:       ***                              
                            :==-:    **#**                              
                             =-=======***                               
                                =::=
EOF
