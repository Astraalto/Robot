*** Settings ***
Library     SeleniumLibrary


*** Variables ***
${URL}      https://www.linkedin.com/jobs/search?keywords=Test+Engineer&location=Finland&geoId=
${BROWSER}  chrome

*** Test Cases ***
Test Engineer Finland
    Open Browser      ${URL}       ${BROWSER} 
    Maximize Browser Window
    Sleep 3s
