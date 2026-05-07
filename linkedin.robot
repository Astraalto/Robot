*** Settings ***
Documentation

...                   pip install robotframework robotframework-seleniumlibrary
...                   ChromeDriver (or GeckoDriver) matching browser version


Library     SeleniumLibrary     timeout=15s    


*** Variables ***
${URL_ALL}              https://www.linkedin.com/jobs/search?keywords=Test+Engineer&location=Finland&geoId=
${URL}                  https://www.linkedin.com  
${BROWSER}              chrome
${JOB_TITLE}            Test Engineer
${JOB_LOCATION}         Finland
${MIN_RESULTS}          1
${JOB_CARD_SELECTOR}    css:.jobs-search__results-list li

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

*** Keywords ***

Open Browser and Load LinkedIn Page
    [Documentation]                Opening a browser and navigate to LinkedIn page 
    [Tags]                         Smoke    LinkedIn    Jobs
    Open Browser                   ${URL}         
    Maximize Browser Window
    Run Keyword And Ignore Error  Accept LinkedIn Cookies

Accept LinkedIn Cookies
    [Documentation]                Clicking and removing Cookie banner
    [Tags]                         Smoke    LinkedIn    Jobs
    Wait Until Element Is Visible  css:button[action-type="ACCEPT"]    timeout=5s
    Click Element                  css:button[action-type="ACCEPT"] 
    Log                            Cookies accepted

Fill In Job Title Search Field
    [Documentation]    Clears and fills the job title input field.
    ${title_field}=    Set Variable    css:input[aria-label="Search by title, skill, or company"]
    Wait Until Element Is Visible    ${title_field}
    Clear Element Text               ${title_field}
    Click Element                    ${title_field}
    Input Text                       ${title_field}    ${JOB_TITLE}
    Log    Entered job title: ${JOB_TITLE}

Get Job Results Count
    [Documentation]     Return number of job listing cards from results
    ${elements}=        Get WebElements    ${JOB_CARD_SELECTOR}
    ${count}=           Get Length         ${elements}
    RETURN              ${count}
