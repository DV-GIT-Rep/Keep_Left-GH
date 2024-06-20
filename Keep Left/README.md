## Avg, Min & Max Speed Calculations
    NOTE: Operation altered from below but doc not updated!!!

### AppData
    define ignoreSpd, kISpd2, kISpd3, oISpd2 & oISpd3 all = true to start
    
### StartStop.swift
    10 secs (runTimerDelay) after Start: set ignoreSpd = false
    
    (not done, but may add)
    on Stop, set all 5 flags = true
    
### calcAvgData func

#### Before Loop
    if ignoreSpd = false, set xISpd2 = false
    
#### During Loop

##### Calculating Distance
    Add .preDistance to calculation. Adds distance prior to ignoreSpd clearing to total.
    
##### Calculating Speed
    if xISpd2 = true:   Set all avg speeds = currentSpeed *prior to stable speed*
    
        *else* if xISpd3 = false:   Set avg speeds = avg as per normal.
        
        *else*  Set .preDistance = distance
                Set startPos = .position
                Set .laps = 0
                Set avg speeds = avg as per normal
    
#### After Loop
    if xISpd2 = false AND xISpd3 = true, set xISpd3 = false & set runTimer = 0.5 (secs)
        *NOTE: runTimer may get set after KL calcAvgData & after Other calcAvgData but sb within 0.5 seconds of each other!*
    


