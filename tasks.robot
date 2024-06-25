*** Settings ***
Library    SeleniumLibrary
Library    Collections
Library    OperatingSystem
Library    String
Library    Process
Library    BuiltIn
Library    RPA.HTTP 
Library    JSON
Library    DateTime


*** Variables *** 
${username}          BUZZWORKS2012           
${password}          Bu$$2024Work$
#getting from views
${aadhaar_number}    ${EMPTY}    
${uan_status}        ${EMPTY}
${uan_num}           ${EMPTY}
${remarks}           ${EMPTY}
${user_uuid}         ${EMPTY}
${created_by}        ${EMPTY}
${time}              ${EMPTY}
${validated_data}    ${EMPTY}
${robot_path}        /home/buzzadmin/Documents/Django/project/tasks.robot
${aaa_str}                
${django_url}                 http://127.0.0.1:8000/
${insert_user_data}            ${django_url}api/insert_user_data/
${url1}                        ${django_url}your-view/
${insert_initial_user_data}    ${django_url}api/insert_initial_user_data/    
${current_index}     0

*** Keywords ***
Click Element When Visible
    [Arguments]    ${PreLocator}      ${Elementtype}    ${PostLocator}
    Wait Until Element Is Visible     ${PreLocator}   timeout=120s    error=${Elementtype} not visible within 2m
    Click Element     ${PreLocator}
    Wait Until Element Is Visible    ${PostLocator}    timeout=30s    error= unable to navigate to next page
    Log    Successfully Clicked on     ${Elementtype}
Open EPF India Website
    # Open Browser    https://www.epfindia.gov.in/site_en/index.php#      Chrome     options=add_experimental_option("detach", True) 
    ${options}=    Evaluate    sys.modules['selenium.webdriver'].ChromeOptions()    sys, selenium.webdriver
    Call Method    ${options}    add_argument    headless
    Open Browser    https://www.epfindia.gov.in/site_en/index.php#    Chrome    options=${options}
    Wait Until Element Is Visible    xpath://*[@id="ecr_panel_1"]    timeout=30s     error=Unbale to launch EPF website..    
Click ECR/Returns/Payment Button
    Click Element        xpath://*[@id="ecr_panel_1"]
    Switch Window        EPFO: Home     timeout=30s
    Maximize Browser Window
    Wait Until Element Is Visible    xpath://*[@id="btnCloseModal"]    timeout=30s     error= Unable to find Alert Popup..
Accept Popup
    Click Button    xpath://*[@id="btnCloseModal"]  
    Log    Opened EPFO login page   
Enter Username and Password
    Wait Until Element Is Visible   xpath://*[@id="username"]    timeout=30s     error=Unable to find username input
    Input Text    xpath://*[@id="username"]     ${username}       
    Input Text    xpath://*[@id="password"]     ${password}                
    Log    Entered username and password   
Click Signin Button
    Wait Until Element Is Visible     //button[@value="Submit"]  timeout=30s
    Click Button        //button[@value="Submit"]
    Sleep    2s
click register individual
    Wait Until Element Is Visible     //*[contains(@class, 'dropdown-toggle') and contains(text(), 'Member')]     timeout=30s
    Click Element   //*[contains(@class, 'dropdown-toggle') and contains(text(), 'Member')]   
    Wait Until Element Is Visible    //ul[@class='dropdown-menu m1']//a[text()='REGISTER-INDIVIDUAL']    timeout=30s  
    Click Element   //ul[@class='dropdown-menu m1']//a[text()='REGISTER-INDIVIDUAL']         
    



fill and submit form for every no_uan 
    [Arguments]           ${member_data}     ${uuid}     ${text}
    Sleep    3s
    ${start_time}=    Get Current Date   result_format=%Y-%m-%d %H:%M:%S.%f
    Log    Starting Time: ${start_time} 

    Wait Until Element Is Visible    //input[@id='memberName']   timeout=30s           error=not found             #name
    Input Text    //input[@id='memberName']      ${member_data['member_name']}

    Run Keyword If    '${member_data['gender']}' == 'F' and '${member_data['marital_status']}' == 'Married'
    ...   Click Element    //select[@id="salutation"]/option[text()="Mrs."]
    ...  ELSE IF    '${member_data['gender']}' == 'F' and '${member_data['marital_status']}' == 'Unmarried'  
    ...    Click Element    //select[@id="salutation"]/option[text()="Ms."]
    ...  ELSE
    ...    Click Element    //select[@id="salutation"]/option[text()="Mr."]
    
    ${gender}=    Set Variable    ${member_data['gender']} 
    ${uppercase}=    Convert To Upper Case    ${gender} 
    ${uppercase}=    Get Substring   ${gender}   0    1
    Wait Until Element Is Visible    //input[@type='radio'][@value='${uppercase}']    timeout=30s                     #gender
    Execute JavaScript    document.querySelector("input[type='radio'][value='${uppercase}']").click()

    ${date_without_time}    Set Variable     ${member_data['date_of_birth']}                           #dob
    Log    ${date_without_time} 
    Wait Until Element Is Visible    //input[@id='dob']        timeout=30s               error=not found
    Input Text        //input[@id='dob']     ${date_without_time}
    Sleep   2s

    ${date}    Set Variable     ${member_data['date_of_joining']}                                         #doj
    Wait Until Element Is Visible   //input[@id="doj"]                 timeout=30s
    Input Text    //input[@id="doj"]    ${date}
    Sleep    2s

    Wait Until Element Is Visible    //input[@id="wages"]             timeout=30s        error=not found         #Monthly EPF Wages as on Joining
    Input Text    //input[@id="wages"]      ${member_data['wages_as_on_joining']}

    
    ${Father's/Husband's Name}=    Set Variable     ${member_data['father_husband_name']}                  #husband/father
    Wait Until Element Is Visible     //input[@id="fatherHusbandName"]         timeout=30s        error=not found
    Input Text   //input[@id="fatherHusbandName"]     ${Father's/Husband's Name}

    ${marital_status}=    Set Variable         ${member_data['marital_status']}                          #martial status
    ${first_letter}=    Get Substring    ${marital_status}    0    1
    ${uppercase_first_letter}=    Convert To Upper Case    ${first_letter}

    Wait Until Element Is Visible     //select[@id="maritalStatus"]/option[@value='${uppercase_first_letter}']     timeout=30s
    Click Element    //select[@id="maritalStatus"]/option[@value='${uppercase_first_letter}']
    Log     ${uppercase_first_letter}

    ${Relationship}=    Set Variable       ${member_data['relationship_with_member']}                      #relation
    ${first}=    Get Substring    ${Relationship}    0    1
    ${uppercase_first}=    Convert To Upper Case    ${first}
    Wait Until Element Is Visible    //select[@id="relation"]/option[@value='${uppercase_first}']        timeout=30s
    Click Element    //select[@id="relation"]/option[@value='${uppercase_first}']
   

    #KYC  DETAILS
    Wait Until Element Is Visible   //*[@id="chkDocTypeId_1"]       timeout=50s
    Click Element    //*[@id="chkDocTypeId_1"]                               #checkbox
    Sleep    1s
    ${Document_number}=    Set Variable          ${member_data['aadhaar_number']} 
    Wait Until Element Is Visible     //*[@id="docNo1"]         timeout=30s                        #aadhaar number
    Input Text     //*[@id="docNo1"]       ${Document_number}
    ${Document_name}=  Set Variable       ${member_data['name_as_on_aadhaar']}                   #aadhaar name
    Wait Until Element Is Visible    //*[@id="nameOnDoc1"]     timeout=30s  
    Input Text    //*[@id="nameOnDoc1"]     ${Document_name}
    Sleep   1s

    #TICKBUTTON
    Wait Until Element Is Visible      //*[@id="aadhaarConsentChkBox"]     timeout=30s       #tickbutton
    Click Element     //*[@id="aadhaarConsentChkBox"]
    Sleep     1s
    Wait Until Element Is Visible   //*[@id="memreg2"]/input     timeout=30s                    #save button    
    Click Element     //*[@id="memreg2"]/input
    Handle Alert
    Sleep  4s   

    # Exit if element is not visible error text 
    ${element_exists}    Run Keyword And Return Status    Element Should Be Visible     xpath=//div[@class='error']         timeout=200s
    ${error_text}=     Run Keyword If    ${element_exists}     Get Text    xpath=//div[@class='error']        
    Log    ${error_text}
    ${aadhaar} =     Set Variable     ${member_data['aadhaar_number']} 
    #take the uan num if present

     # : conditon 
    ${contains_colon}=    Run Keyword And Return Status    Should Contain   ${error_text}    :
    IF  '${contains_colon}' == 'True' 
        ${uan_num}=  Split String  ${error_text}  separator=:
        ${uan} =  Set Variable    ${uan_num}[1] 
        ${uan_clean}=    Replace String    ${uan}    .    ${EMPTY}
        ${text}=    Set Variable      ${uan_num}[0]  
        yes button process    ${text}     ${member_data}     ${uuid}
    ELSE  
        ${aadhaar_number}=  Set Variable  ${aadhaar}   
        ${uan_status}=  Set Variable   Newly Added
        ${uan_num}=    Set Variable    None 
        ${remarks}=    Set Variable     ${error_text} 
    END





yes button process
    [Arguments]     ${member_data}       ${uuid}      ${text}
    Sleep    4s 
    ${start_time}=    Get Current Date    result_format=%Y-%m-%d %H:%M:%S.%f
    Log    Starting Time: ${start_time}
    ${locator}=    Set Variable    //input[@type='radio'][@name='isPreviousEmployee'][@value='Y']
    Wait Until Element Is Visible    ${locator}          timeout= 120s
    Execute JavaScript    document.getElementById('previousEmployementYes').click();

    ${uan_number}=       Set Variable      ${text}                 #uan                   
    Wait Until Element Is Visible    //input[@id="uan"]    timeout=80s
    Input Text    //input[@id="uan"]    ${uan_number}

    ${date_without_time}=    Set Variable        ${member_data['date_of_birth']}                        #dob
    Log    ${date_without_time} 
    Wait Until Element Is Visible   //input[@id="dobVerify"]               timeout=30s        
    Input Text         //input[@id="dobVerify"]     ${date_without_time}
    Sleep     2s

    ${Name}=      Set Variable        ${member_data['name_as_on_aadhaar']}                           #name as aadhar            
    Wait Until Element Is Visible     //input[@id="nameVerify"]       timeout=30s                  
    Input Text    //input[@id="nameVerify"]    ${Name}
    
    ${AADHAAR}=   Set Variable         ${member_data['aadhaar_number']}                              #aadhar number
    Wait Until Element Is Visible  //input[@id="aadharVerify"]
    Input Text    //input[@id="aadharVerify"]   ${AADHAAR}
    
    #TICK BUTTON
    Wait Until Element Is Visible    //input[@id="aadhaarConsentChkBox"]   timeout=30s       error=not found      #tickbox
    Click Element   //input[@id="aadhaarConsentChkBox"] 
    
    #verify
    Wait Until Element Is Visible   //input[@value="Verify"]    timeout=30s                error=not found       #verify button   
    Click Element     //input[@value="Verify"]

    Wait Until Element Is Visible    //div[@role="alert"]        timeout=200s                error=not found    #text extraction 
    ${error_message}=    Get Text    xpath=//div[@role="alert"]
    Log     ${error_message} 
    ${error} =    Strip String     ${error_message} 
    Log   ${error} 
    Sleep  2s
    #memeber name mismatch
    IF   '${error}' == 'Member name mismatch.'	
        Wait Until Element Is Visible   //div[@id="memDetailsModal"]//button[contains(text(),'Close')]    timeout=30s 
        Click Element     //div[@id="memDetailsModal"]//button[contains(text(),'Close')] 

        Wait Until Element Is Visible    //*[@id="memberRegistration"]//table/tbody/tr/td/pre     timeout=30s  
        ${mismatch_condition}=    Get Text    //*[@id="memberRegistration"]//table/tbody/tr/td/pre

        Wait Until Element Is Visible    //input[@id="nameVerify"]    timeout=30s 
        Input Text    //input[@id="nameVerify"]    ${mismatch_condition}
        
        #verify
        Wait Until Element Is Visible   //input[@value="Verify"]      timeout=60s                      #verify button   
        Click Element     //input[@value="Verify"]
        Sleep    6s
        ${close_button_visible}=    Run Keyword And Return Status    Element Should Be Visible    //div[@id="memDetailsModal"]//button[contains(text(),'Close')]   
        ${ok_button_visible}=    Run Keyword And Return Status       Element Should Be Visible   //div[@id="memDetailsModal"]//button[contains(text(),'Ok')] 
        Run Keyword If    ${close_button_visible}    Click Button     //div[@id="memDetailsModal"]//button[contains(text(),'Close')] 
        Run Keyword If    ${ok_button_visible}    Click Button    //div[@id="memDetailsModal"]//button[contains(text(),'Ok')]
        Wait Until Element Is Visible    //div[@role="alert"]        timeout=200s                error=not found    #text extraction 
        ${message}=    Get Text    xpath=//div[@role="alert"]
        Log    ${message}
        ${aadhaar_number} =     Set Variable   ${member_data['aadhaar_number']} 
        ${uan_status} =  Set Variable       Already Exist 
        ${uan_num}=    Set Variable         ${text}
        ${remarks}=     Set Variable       ${message}    
        Log    User UUID: ${uuid}
        Log    Created By: ${created_by}
    ELSE
        ${close_button_visible}=    Run Keyword And Return Status    Element Should Be Visible    //div[@id="memDetailsModal"]//button[contains(text(),'Close')]   
        ${ok_button_visible}=    Run Keyword And Return Status    Element Should Be Visible   //div[@id="memDetailsModal"]//button[contains(text(),'Ok')] 
        Run Keyword If    ${close_button_visible}    Click Button     //div[@id="memDetailsModal"]//button[contains(text(),'Close')] 
        Run Keyword If    ${ok_button_visible}    Click Button    //div[@id="memDetailsModal"]//button[contains(text(),'Ok')] 

        ${aadhaar} =     Set Variable      ${member_data['aadhaar_number']} 
        ${uan_present}=       Set Variable     ${text}                #uan  
        ${aadhaar_number}=  Set Variable  ${aadhaar}   
        ${uan_status} =  Set Variable     Already Exist  
        ${uan_num} =     Set Variable     ${text}
        ${remarks}=     Set Variable       ${error_message}
        Log    User UUID: ${uuid}
        
    ${end_time}=    Get Current Date    result_format=%Y-%m-%d %H:%M:%S.%f
    Log    Ending Time: ${end_time}
    ${time}=    Subtract Date From Date    ${end_time}    ${start_time}    
    ${time}=    Evaluate    "${time}"[:-7]    # Extract only time component
    Log    Overall Time Taken: ${time}
    RPA.HTTP.Create Session    UserSession    http://localhost:8000
    Log    User UUID: ${uuid}
    Log    Created By: ${created_by}
    ${data}=    Create Dictionary   aadhaar_number=${aadhaar_number}    uan_status=${uan_status}    uan_num=${uan_num}    remarks=${remarks}    user_uuid=${uuid}   time=${time}
    Log    ${data}
    ${headers}=    Create Dictionary    Content-Type=application/json
    Log     ${headers}
    ${response}=    RPA.HTTP.POST On Session    UserSession    ${insert_user_data}    json=${data}    headers=${headers}
    Log    ${response}
    Sleep    5s
    END 

    Wait Until Element Is Visible     ${locator}          timeout=30s
    ${locator}=    Set Variable    //input[@type='radio'][@name='isPreviousEmployee'][@value='N']
    Execute JavaScript    document.getElementById('previousEmployementNo').click();
    Sleep    5s   


fill and submit form for every uan is_present
    [Arguments]           ${member_data}       ${uuid}  
    Sleep    4s 
    ${start_time}=    Get Current Date    result_format=%Y-%m-%d %H:%M:%S.%f
    Log    Starting Time: ${start_time}
    ${locator}=    Set Variable    //input[@type='radio'][@name='isPreviousEmployee'][@value='Y']
    Wait Until Element Is Visible    ${locator}          timeout= 120s
    Execute JavaScript    document.getElementById('previousEmployementYes').click();

    ${uan_number}=       Set Variable      ${member_data['Universal_Account']}                  #uan                   
    Wait Until Element Is Visible    //input[@id="uan"]    timeout=80s
    Input Text    //input[@id="uan"]    ${uan_number}

    ${date_without_time}=    Set Variable        ${member_data['date_of_birth']}                        #dob
    Log    ${date_without_time} 
    Wait Until Element Is Visible   //input[@id="dobVerify"]               timeout=30s        
    Input Text         //input[@id="dobVerify"]     ${date_without_time}
    Sleep     2s

    ${Name}=      Set Variable        ${member_data['name_as_on_aadhaar']}                           #name as aadhar            
    Wait Until Element Is Visible     //input[@id="nameVerify"]       timeout=30s                  
    Input Text    //input[@id="nameVerify"]    ${Name}
    
    ${AADHAAR}=   Set Variable         ${member_data['aadhaar_number']}                              #aadhar number
    Wait Until Element Is Visible  //input[@id="aadharVerify"]
    Input Text    //input[@id="aadharVerify"]   ${AADHAAR}
    
    #TICK BUTTON
    Wait Until Element Is Visible    //input[@id="aadhaarConsentChkBox"]   timeout=30s       error=not found      #tickbox
    Click Element   //input[@id="aadhaarConsentChkBox"] 
    
    #verify
    Wait Until Element Is Visible   //input[@value="Verify"]    timeout=30s                error=not found       #verify button   
    Click Element     //input[@value="Verify"]

    Wait Until Element Is Visible    //div[@role="alert"]        timeout=200s                error=not found    #text extraction 
    ${error_message}=    Get Text    xpath=//div[@role="alert"]
    Log     ${error_message} 
    ${error} =    Strip String     ${error_message} 
    Log   ${error} 
    Sleep  2s
    #memeber name mismatch
    IF   '${error}' == 'Member name mismatch.'	
        Wait Until Element Is Visible   //div[@id="memDetailsModal"]//button[contains(text(),'Close')]    timeout=30s 
        Click Element     //div[@id="memDetailsModal"]//button[contains(text(),'Close')] 

        Wait Until Element Is Visible    //*[@id="memberRegistration"]//table/tbody/tr/td/pre     timeout=30s  
        ${mismatch_condition}=    Get Text    //*[@id="memberRegistration"]//table/tbody/tr/td/pre

        Wait Until Element Is Visible    //input[@id="nameVerify"]    timeout=30s 
        Input Text    //input[@id="nameVerify"]    ${mismatch_condition}
        
        #verify
        Wait Until Element Is Visible   //input[@value="Verify"]      timeout=60s                      #verify button   
        Click Element     //input[@value="Verify"]
        Sleep    6s
        ${close_button_visible}=    Run Keyword And Return Status    Element Should Be Visible    //div[@id="memDetailsModal"]//button[contains(text(),'Close')]   
        ${ok_button_visible}=    Run Keyword And Return Status       Element Should Be Visible   //div[@id="memDetailsModal"]//button[contains(text(),'Ok')] 
        Run Keyword If    ${close_button_visible}    Click Button     //div[@id="memDetailsModal"]//button[contains(text(),'Close')] 
        Run Keyword If    ${ok_button_visible}    Click Button    //div[@id="memDetailsModal"]//button[contains(text(),'Ok')]
        Wait Until Element Is Visible    //div[@role="alert"]        timeout=200s                error=not found    #text extraction 
        ${message}=    Get Text    xpath=//div[@role="alert"]
        Log    ${message}
        ${aadhaar_number} =     Set Variable   ${member_data['aadhaar_number']} 
        ${uan_status} =  Set Variable       Already Exist 
        ${uan_num}=    Set Variable     ${member_data['Universal_Account']}
        ${remarks}=     Set Variable       ${message}    
        Log    User UUID: ${uuid}
        Log    Created By: ${created_by}
    ELSE
        ${close_button_visible}=    Run Keyword And Return Status    Element Should Be Visible    //div[@id="memDetailsModal"]//button[contains(text(),'Close')]   
        ${ok_button_visible}=    Run Keyword And Return Status    Element Should Be Visible   //div[@id="memDetailsModal"]//button[contains(text(),'Ok')] 
        Run Keyword If    ${close_button_visible}    Click Button     //div[@id="memDetailsModal"]//button[contains(text(),'Close')] 
        Run Keyword If    ${ok_button_visible}    Click Button    //div[@id="memDetailsModal"]//button[contains(text(),'Ok')] 

        ${aadhaar} =     Set Variable      ${member_data['aadhaar_number']} 
        ${uan_present}=       Set Variable      ${member_data['Universal_Account']}                   #uan  
        ${aadhaar_number}=  Set Variable  ${aadhaar}   
        ${uan_status} =  Set Variable     Already Exist  
        ${uan_num} =     Set Variable     ${member_data['Universal_Account']}
        ${remarks}=     Set Variable       ${error_message}
        Log    User UUID: ${uuid}
        
    ${end_time}=    Get Current Date    result_format=%Y-%m-%d %H:%M:%S.%f
    Log    Ending Time: ${end_time}
    ${time}=    Subtract Date From Date    ${end_time}    ${start_time}    
    ${time}=    Evaluate    "${time}"[:-7]    # Extract only time component
    Log    Overall Time Taken: ${time}
    RPA.HTTP.Create Session    UserSession    http://localhost:8000
    Log    User UUID: ${uuid}
    Log    Created By: ${created_by}
    ${data}=    Create Dictionary   aadhaar_number=${aadhaar_number}    uan_status=${uan_status}    uan_num=${uan_num}    remarks=${remarks}    user_uuid=${uuid}   time=${time}
    Log    ${data}
    ${headers}=    Create Dictionary    Content-Type=application/json
    Log     ${headers}
    ${response}=    RPA.HTTP.POST On Session    UserSession    ${insert_user_data}    json=${data}    headers=${headers}
    Log    ${response}
    Sleep    5s
    END 

    Wait Until Element Is Visible     ${locator}          timeout=30s
    ${locator}=    Set Variable    //input[@type='radio'][@name='isPreviousEmployee'][@value='N']
    Execute JavaScript    document.getElementById('previousEmployementNo').click();
    Sleep    5s   
   
Handle Alert And Click Radio Button
    [Arguments]  ${locator}                        #(yes/no)radian button purpose 
    Run Keyword And Ignore Error    Handle Alert
    Wait Until Element Is Visible    ${locator}    timeout=30s
    Click Element    ${locator}





*** Test Cases ***  
Automate EPFO Webpage
    # Get the starting timestamp
    ${start_time}=    Get Current Date    result_format=%Y-%m-%d %H:%M:%S.%f
    Log    Starting Time: ${start_time}
    Open EPF India Website
    Click ECR/Returns/Payment Button
    Accept Popup
    Enter Username and Password
    Click Signin Button
    click register individual


Extract All Member Data 
    Log   ${validated_data}
    ${data_list}=    Evaluate    json.loads($validated_data)    json
    ${current_index}=    Get Length    ${data_list}
    ${total_index}=    Set Variable    ${current_index}
    ${all_member_data}=    Create List
    ${current_index}=    Set Variable    0
    FOR    ${member_data}    IN    @{data_list}
        Log    ${member_data['user_id']}
        ${member_info}=    Create Dictionary    Member Name=${member_data['member_name']}    Gender=${member_data['gender']}    Father/Husband Name=${member_data['father_husband_name']}    Relationship with Member=${member_data['relationship_with_member']}    Nationality=${member_data['nationality']}    Marital Status=${member_data['marital_status']}    Aadhaar Number=${member_data['aadhaar_number']}    Name as on Aadhaar=${member_data['name_as_on_aadhaar']}     Date of Birth=${member_data['date_of_birth']}    Date of Joining=${member_data['date_of_joining']}    Universal_Account=${member_data['Universal_Account']}    wages_as_on_joining=${member_data['wages_as_on_joining']}
        Append To List    ${all_member_data}    ${member_info}
        ${current_index}=    Evaluate    ${current_index} + 1 
        Log    All Member Data: ${all_member_data}
        ${uuid}=    Evaluate    str(uuid.uuid4())
        Log    Generated UUID:${uuid}
        ${data}=    Create Dictionary   ind_user=${member_info}   username=${member_data['member_name']}     uuid=${uuid}   index=${current_index}    len_validated_data=${total_index}    user_id=${member_data['user_id']}
        Log    ${data}
        Log    ${member_data['Universal_Account']}
        ${insert_initial_user_data}=    Set Variable    /api/insert_initial_user_data/ 
        ${headers}=    Create Dictionary    Content-Type=application/json
        Log     ${headers}
        RPA.HTTP.Create Session    UserSession    http://localhost:8000     debug=1
        ${response}=    RPA.HTTP.POST On Session    UserSession    ${insert_initial_user_data}     json=${data}    headers=${headers}
        Log    ${response}
        Run Keyword If    '${member_data['Universal_Account']}' != 'None'    fill and submit form for every uan is_present    ${member_data}    ${uuid}   ELSE    fill and submit form for every no_uan    ${member_data}     ${uuid}      ${text}
        Sleep   5s 
    END
    # Get the ending timestamp
    ${end_time}=    Get Current Date    result_format=%Y-%m-%d %H:%M:%S.%f
    Log    Ending Time: ${end_time}

















