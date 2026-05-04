*** Settings ***
Documentation

...                   pip install robotframework robotframework-seleniumlibrary
...                   ChromeDriver (or GeckoDriver) matching browser version


Library     SeleniumLibrary     timeout=15s    


*** Variables ***
${URL_ALL}          https://www.linkedin.com/jobs/search?keywords=Test+Engineer&location=Finland&geoId=
${URL}              https://www.linkedin.com  
${BROWSER}          chrome
${JOB_TITLE}        Test Engineer
${JOB_LOCATION}     Finland
${MIN_RESULTS}      1

*** Test Cases ***

Test Engineer Finland
    [Documentation] 
    [Tags]                        Smoke     Easy
    Open Browser                  ${URL_ALL}       ${BROWSER} 
    Maximize Browser Window
    Sleep  3s

Linkedin Page Loaded Successfully
    [Documentation]                Verify that page opened without issues
    [Tags]                         Smoke
    Open Browser                   ${URL}      ${BROWSER}
    Title Should Be                jobs
    Page Should Contain Element    css:input[aria-label="Search by title, skill, or company"]
    Log                            LinkedIn page loaded successfully

Job Search Returns Results
    [Documentation]                Verify that at least one result returns from job search
    [Tags]                         Smoke    LinkedIn    Jobs
    ${count}=                      Get Job Results Count
    Log                            Found ${count} job listing(s) for "${JOB_TITLE}" in "${JOB_LOCATION}" 
    Should Be True                 ${count}  >=  ${MIN_RESULTS}
    ...    msg=Expected at least ${MIN_RESULTS} result(s), but got ${count}

Accept LinkedIn Cookies
    [Documentation]                Clicking and removing Cookie banner
    [Tags]                         Smoke    LinkedIn    Jobs
    Wait Until Element Is Visible  css:button[action-type="ACCEPT"]    timeout=5s
    Click Element                  css:button[action-type="ACCEPT"] 
    Log                            Cokkies accepted