*** Settings ***
Documentation       Orders robots from RobotSpareBin Industries Inc.
...                 Saves the order HTML receipt as a PDF file.
...                 Saves the screenshot of the ordered robot.
...                 Embeds the screenshot of the robot to the PDF receipt.
...                 Creates ZIP archive of the receipts and the images.
...

Library             RPA.Browser.Selenium    auto_close=${FALSE}
Library             RPA.HTTP
Library             RPA.Excel.Files
Library             RPA.PDF
Library             RPA.Tables
Library             RPA.Archive

Task Teardown       Close Browser


*** Tasks ***
Order robots from RobotSpareBin Industries Inc
    Open the website
    Maximize Browser Window
    #Set Selenium Speed    0.1
    ${orders}=    Get orders
    FOR    ${row}    IN    @{orders}
        Click OK
        Create order    ${row}
        Preview order
        Wait Until Keyword Succeeds    3x    1s    Order robot
        Create order PDF    ${row}
        Order another
        Log    ${row}
    END
    Zip receipts


*** Keywords ***
Get orders
    Download    https://robotsparebinindustries.com/orders.csv    overwrite=True
    ${orders}=    Read table from CSV    orders.csv
    Log    Found colums: ${orders}
    RETURN    ${orders}

Open the website
    Open Available Browser    https://robotsparebinindustries.com/#/robot-order

Click OK
    Click Button    OK

Create order
    [Arguments]    ${row}
    Select From List By Value    head    ${row}[Head]
    Select Radio Button    body    ${row}[Body]
    Press Keys    none    TAB
    Press Keys    none    ${row}[Legs]
    Click Button    Show model info
    Input Text    address    ${row}[Address]

Preview order
    Click Button    Preview
    #${preview_image}=    Capture Element Screenshot    robot-preview-image

Order robot
    Wait Until Keyword Succeeds    3x    1s    Click Button    id:order
    Wait Until Page Contains    Receipt

Order another
    Click Button    order-another

Create order PDF
    [Arguments]    ${row}
    Capture Element Screenshot    robot-preview-image    ${OUTPUTDIR}/images/Order ${row}[Order number].png
    Wait Until Element Is Visible    receipt
    #${order info}=    Get Text    receipt
    ${order_info}=    Get Element Attribute    receipt    outerHTML
    Html To Pdf    ${order_info}    ${OUTPUT_DIR}${/}pdf/Order ${row}[Order number].pdf

    ${robotPNG}=    Create List    ${OUTPUT_DIR}${/}pdf/Order ${row}[Order number].pdf
    ...    ${OUTPUTDIR}/images/Order ${row}[Order number].png
    Add Files To Pdf    ${robotPNG}    ${OUTPUT_DIR}${/}pdf/Order ${row}[Order number].pdf

    #$(DOWNLOAD_DIR}$(/}robot$(ORDER}[Order number].png
    #§{DOWNLOAD DIR&$f/Preceipt$fORDER}[Order number].pdf

Zip receipts
    Archive Folder With ZIP    ${OUTPUT_DIR}${/}pdf    receipts.zip    overwrite=True

Minimal task
    Log    Done.
