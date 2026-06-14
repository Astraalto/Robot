*** Settings ***
Documentation

...                   pip install robotframework robotframework-seleniumlibrary
...                   ChromeDriver (or GeckoDriver) matching browser version


Library     SeleniumLibrary     timeout=15s    implicit_wait=3s
Library     RequestsLibrary


*** Variables ***
${URL_ALL}              https://www.linkedin.com/jobs/search?keywords=Test+Engineer&location=Finland&geoId=
${URL}                  https://www.linkedin.com/jobs/search?keywords=&location=Finland&geoId=100456013&trk=public_jobs_jobs-search-bar_search-submit&position=1&pageNum=0
${JOBS_URL}             https://www.linkedin.com/jobs/search/
${BROWSER}              chrome
${JOB_TITLE}            Test Engineer
${JOB_LOCATION}         Finland
${MIN_RESULTS}          1
${JOB_CARD_SELECTOR}    css:.jobs-search__results-list li
${RESULTS_CONTAINER}    css:.jobs-search__results-list
${ACCEPT}               css:button.artdeco-global-alert-action:nth-child(1)
${CLOSE WINDOW}         css:#base-contextual-sign-in-modal > div > section > button > icon > svg > path
${JOB_TITLES}           Test Engineer
...                     QA Engineer
...                     Test Analyst
...                     Test Automation Engineer
${CITIES}               Helsinki
...                     Espoo
...                     Tampere
...                     Vantaa
...                     Turku
...                     Oulu

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
    Wait Until Element Is Visible  ${ACCEPT}     timeout=5s
    Click Element                  ${ACCEPT}  
    Log                            Cookies accepted

Navigate To LinkedIn Jobs
    [Documentation]    Navigates back to the LinkedIn Jobs base URL for a fresh search.
    Go To    ${JOBS_URL}
    Wait Until Element Is Visible    css:#job-search-bar-keywords    timeout=30s

Fill In Job Title Search Field
    [Documentation]    Clears and fills the job title input field.
    ${title_field}=    Set Variable    css:#job-search-bar-keywords
    Wait Until Element Is Visible      ${title_field}
    Clear Element Text                 ${title_field}
    Click Element                      ${title_field}
    Input Text    ${title_field}    ${JOB_TITLE}
    ${value}=    Get Element Attribute    ${title_field}    value
    Log    Field value after input: ${value}    level=WARN

Fill In Location Search Field
    [Documentation]  Clears and fills location search field
    ${location_field}=    Set Variable   css:#job-search-bar-location
    Wait Until Element Is Visible      ${location_field}
    Click Element Three Times          ${location_field}
    Input Text                         ${location_field}    ${JOB_LOCATION}
    Log    Enetered location: ${JOB_LOCATION}

Get Job Results Count
    [Documentation]     Return number of job listing cards from results
    ${elements}=        Get WebElements    ${JOB_CARD_SELECTOR}
    ${count}=           Get Length         ${elements}
    RETURN              ${count}

Wait Until Results Are Loaded
    [Documentation]     Waits for the job results appear on the page
    Wait Until Element Is Visible  ${RESULTS_CONTAINER}      timeout=20s
    Sleep    1s     reason=Allow dynamic content to fully render

Click Element Three Times
    [Documentation]      Clciks the element three times to select all text
    [Arguments]          ${locator}
    Click Element        ${locator}
    Click Element        ${locator}
    Click Element        ${locator}  

Submit Job Search
    [Documentation]      Execute searching by clicking Search button
    ${location_field}=   Set Variable   css:#job-search-bar-location
    Press Keys           ${location_field}     RETURN
    ${url}=    Get Location
    Log    URL after search: ${url}    level=WARN

Should Contain Any
    [Documentation]    Passes if the given text contains at least one of the provided substrings.
    [Arguments]        ${text}    @{substrings}
    FOR    ${substring}    IN    @{substrings}
        ${found}=    Run Keyword And Return Status    Should Contain    ${text}    ${substring}
        IF    ${found}
            Log    Found expected keyword: "${substring}"
            RETURN
        END
    END
    Fail    None of the expected substrings were found in the text: ${substrings}

Apply Remote Filter
    [Documentation]    Clicks the Remote filter option on the results page.
    ${remote_filter}=    Set Variable    css:button[aria-label*="Remote"]
    Wait Until Element Is Visible    ${remote_filter}    timeout=15s
    Click Element                    ${remote_filter}
    Log    Remote filter applied

Fill In Search Fields
    [Documentation]    Fills in both the title and location search fields and submits.
    [Arguments]    ${title}    ${location}
    ${title_field}=       Set Variable    css:#job-search-bar-keywords
    ${location_field}=    Set Variable    css:#job-search-bar-location
    Wait Until Element Is Visible    ${title_field}
    Click Element Three Times        ${title_field}
    Input Text                       ${title_field}    ${title}
    Click Element Three Times        ${location_field}
    Input Text                       ${location_field}    ${location}
    Press Keys                       ${location_field}    RETURN

Apply Full Time Filter
    [Documentation]    Opens the job type filter and selects Full-time.
    ${jobtype_button}=    Set Variable    css:button[aria-label*="Job type"]
    Wait Until Element Is Visible    ${jobtype_button}    timeout=15s
    Click Element                    ${jobtype_button}
    ${fulltime_option}=    Set Variable    css:label[for*="full-time"], css:label[for*="fullTime"]
    Wait Until Element Is Visible    ${fulltime_option}    timeout=10s
    Click Element                    ${fulltime_option}
    Press Keys                       NONE    RETURN

*** Test Cases ***

Request Check Linkedin Page
    [Documentation]              Check if Linkedin page is working
    [Tags]                       Smoke Easy
    ${response}=    GET  https://www.linkedin.com/  params=query=ciao  expected_status=200

Test Engineer Finland            
    [Documentation]               Simple check
    [Tags]                        Smoke     Easy
    Open Browser                  ${URL_ALL}       ${BROWSER} 
    Wait Until Results Are Loaded
    Maximize Browser Window
    Click Element                 ${CLOSE WINDOW}
    Sleep  3s

Search For Test Engineer Jobs In Finland
    [Documentation]               Enter the search criteria for Test Engineer positions 
    [Tags]                        Smoke    LinkedIn    Jobs
    Fill In Job Title Search Field
    Fill In Location Search Field
    Submit Job Search
    Wait Until Results Are Loaded
    Log                           Search submitted and results loaded

Linkedin Page Loaded Successfully
    [Documentation]                Verify that page opened without issues
    [Tags]                         Smoke
    ${title}=    Get Title 
    Open Browser                   ${URL}      ${BROWSER}
    Should Contain   ${title}  Työpaikat
    Page Should Contain Element    css:.switcher-tabs__placeholder-text
    Log                            LinkedIn page loaded successfully

Job Search Returns Results
    [Documentation]                Verify that at least one result returns from job search
    [Tags]                         Smoke    LinkedIn    Jobs
    ${count}=                      Get Job Results Count
    Log                            Found ${count} job listing(s) for "${JOB_TITLE}" in "${JOB_LOCATION}" 
    Should Be True    ${count} >= ${MIN_RESULTS}
    ...    Expected at least ${MIN_RESULTS} result(s), but got ${count}

Job Listings Contain Relevant Keywords
    [Documentation]    Spot-check that visible job cards mention Test Engineer or related terms.
    [Tags]    validation    linkedin    jobs
    Wait Until Element Is Visible    ${RESULTS_CONTAINER}    timeout=30s
    Wait Until Page Contains Element    ${JOB_CARD_SELECTOR}    timeout=30s
    ${page_text}=    Get Text    ${RESULTS_CONTAINER}
    ${lower_text}=    Evaluate    $page_text.lower()
    Should Contain Any    ${lower_text}    test engineer    qa engineer    quality engineer
    ...    test automation    testiautomaatio    laadunvarmistus    testaaja    tester

Job Listings Are Located In Finland
    [Documentation]                Verify that job offers are in proper location
    [Tags]                         Verification      linkedin     Dinland
    ${page_text}=        Get Text    ${RESULTS_CONTAINER}
    ${lower_text}=       Evaluate    $page_text.lower()
    Should Contain Any    ${lower_text}    finland    helsinki    tampere    espoo    oulu    turku

Search Returns Results For QA Titles
    [Documentation]       Verify that search returns results for related QA titles
    [Tags]                search    titles    linkedin 
    FOR     ${title}    IN   @{JOB_TITLES}
        Log   /nSearching for:  ${title}  in Finland    # level=WARN
        Navigate To Linkedin Jobs
        Fill In Search Fields   ${title}    Finland
        Wait Until Results Are Loaded
        ${count}=   Get Job Results Count
        Log   Found  ${count}  result(s)  for  "${title}"   #  level=WARN
        Should Be True     ${count}  >=  ${MIN_RESULTS}   
        ...      Expected at least ${MIN_RESULTS} results(s) for "${title}", got ${count}
    END 

Search Returns Results In Finnish Cities
    [Documentation]    Verify Test Engineer search returns results in major Finnish cities.
    [Tags]    search    cities    linkedin
    FOR    ${city}    IN    @{CITIES}
        Log    \nSearching for Test Engineer in: ${city}    level=WARN
        Navigate To LinkedIn Jobs
        Fill In Search Fields    Test Engineer    ${city}
        Wait Until Results Are Loaded
        ${count}=    Get Job Results Count
        Log    Found ${count} result(s) in ${city}    level=WARN
        Should Be True    ${count} >= ${MIN_RESULTS}
        ...    Expected at least ${MIN_RESULTS} result(s) in "${city}", got ${count}
    END

Search With Full Time Filter Returns Results
    [Documentation]    Verify Test Engineer full-time jobs are available in Finland.
    [Tags]    search    filters    fulltime    linkedin
    Navigate To LinkedIn Jobs
    Fill In Search Fields    Test Engineer    Finland
    Wait Until Results Are Loaded
    Apply Full Time Filter
    Wait Until Results Are Loaded
    ${count}=    Get Job Results Count
    Log    Found ${count} full-time result(s)    level=WARN
    Should Be True    ${count} >= ${MIN_RESULTS}
    ...    Expected at least ${MIN_RESULTS} full-time result(s), got ${count}