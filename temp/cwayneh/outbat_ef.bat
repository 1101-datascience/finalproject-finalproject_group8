@echo off
set fn="..\dsout.%date:~5,2%%date:~8,2%.ef.log"
set tgt="..\bin\Rscript.exe"
echo --------BEGIN at %date% %time% >>%fn%2>&1
cd ..
%tgt% extremes_filter.R --method IQR --range -3,3 --target 2:30 --train train.csv --test test.csv --report output/performance.ef.csv >>%fn%2>&1
%tgt% extremes_filter.R --method std --range -3,3 --target 2:30 --train train.csv --test test.csv --report output/performance.ef.csv >>%fn%2>&1
%tgt% extremes_filter.R --method IQR --range -3,3 --target 30:30 --train train.csv --test test.csv --report output/performance.ef.csv >>%fn%2>&1
%tgt% extremes_filter.R --method std --range -3,3 --target 30:30 --train train.csv --test test.csv --report output/performance.ef.csv >>%fn%2>&1
echo END at %date% %time%-------- >>%fn%2>&1
pause
