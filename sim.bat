@echo off
REM Get the first argument passed to the BAT file
set IMAGE_INDEX=%1

REM If no argument is provided, prompt the user and exit
if "%IMAGE_INDEX%"=="" (
    echo Usage: sim.bat [image_index]
    exit /b 1
)

REM Call Python script with argument
python model.py %IMAGE_INDEX%

REM Run QuestaSim simulation
C:\intelFPGA\23.1std\questa_fse\win64\vsim -c -do "do SIM/run.do"

REM Run second Python script
python convert2decimal.py