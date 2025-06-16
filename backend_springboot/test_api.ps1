# Test API endpoints for BlueMoon Apartment Management System
$baseUrl = "http://localhost:8080/api"
$results = @()

# Helper function to make HTTP requests and record results
function Test-Endpoint {
    param (
        [string]$testName,
        [string]$testObject,
        [string]$description,
        [string]$method,
        [string]$endpoint,
        [object]$body,
        [string]$expectedStatus,
        [hashtable]$headers = @{
            "Content-Type" = "application/json"
        }
    )

    $input = if ($body) { $body | ConvertTo-Json } else { "No input body" }
    
    try {
        if ($method -eq "GET") {
            $response = Invoke-RestMethod -Uri "$baseUrl$endpoint" -Method $method -Headers $headers -ErrorAction Stop
        } else {
            $response = Invoke-RestMethod -Uri "$baseUrl$endpoint" -Method $method -Body ($body | ConvertTo-Json) -Headers $headers -ErrorAction Stop
        }
        $status = "PASS"
        $actualOutput = $response | ConvertTo-Json
    } catch {
        $status = "FAIL"
        $actualOutput = $_.Exception.Message
    }

    $results += @{
        testName = $testName
        testObject = $testObject
        description = $description
        input = $input
        expectedOutput = $expectedStatus
        actualOutput = $actualOutput
        status = $status
    }
}

# Test Case 1: Register Admin User
Test-Endpoint `
    -testName "TC001_RegisterAdmin" `
    -testObject "Đăng ký" `
    -description "Kiểm tra đăng ký user admin mới" `
    -method "POST" `
    -endpoint "/auth/register" `
    -body @{
        email = "admin@bluemoon.com"
        password = "Admin@123"
        fullName = "Admin User"
        role = "ADMIN"
    } `
    -expectedStatus "201 Created"

# Test Case 2: Login Admin
Test-Endpoint `
    -testName "TC002_LoginAdmin" `
    -testObject "Đăng nhập" `
    -description "Kiểm tra đăng nhập với thông tin admin hợp lệ" `
    -method "POST" `
    -endpoint "/auth/login" `
    -body @{
        email = "admin@bluemoon.com"
        password = "Admin@123"
    } `
    -expectedStatus "200 OK"

# Store token from login response for subsequent requests
$token = $results[-1].actualOutput.token
$authHeaders = @{
    "Content-Type" = "application/json"
    "Authorization" = "Bearer $token"
}

# Test Case 3: Create Household
Test-Endpoint `
    -testName "TC003_CreateHousehold" `
    -testObject "Quản lý hộ gia đình" `
    -description "Tạo hộ gia đình mới với thông tin hợp lệ" `
    -method "POST" `
    -endpoint "/households" `
    -headers $authHeaders `
    -body @{
        apartmentNumber = "101"
        area = 100
        ownerName = "Nguyễn Văn A"
    } `
    -expectedStatus "201 Created"

# Test Case 4: Get All Households
Test-Endpoint `
    -testName "TC004_GetAllHouseholds" `
    -testObject "Quản lý hộ gia đình" `
    -description "Lấy danh sách tất cả hộ gia đình" `
    -method "GET" `
    -endpoint "/households" `
    -headers $authHeaders `
    -expectedStatus "200 OK"

# Test Case 5: Add Household Member
Test-Endpoint `
    -testName "TC005_AddHouseholdMember" `
    -testObject "Quản lý thành viên" `
    -description "Thêm thành viên mới vào hộ gia đình" `
    -method "POST" `
    -endpoint "/households/1/members" `
    -headers $authHeaders `
    -body @{
        name = "Nguyễn Văn B"
        identityCard = "001122334455"
        relationship = "Con"
    } `
    -expectedStatus "201 Created"

# Export results to JSON and CSV
$timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
$results | ConvertTo-Json -Depth 10 | Out-File "bluemoon-test-results-$timestamp.json"

$csvHeader = "Test Name,Test Object,Description,Input,Expected Output,Actual Output,Status"
$csvContent = $results | ForEach-Object {
    "{0},{1},{2},{3},{4},{5},{6}" -f `
        $_.testName,
        $_.testObject,
        $_.description,
        ($_.input -replace ',', ';'),
        $_.expectedOutput,
        ($_.actualOutput -replace ',', ';'),
        $_.status
}

$csvHeader | Out-File "bluemoon-test-results-$timestamp.csv"
$csvContent | Add-Content "bluemoon-test-results-$timestamp.csv"

Write-Host "Test results exported to bluemoon-test-results-$timestamp.json and bluemoon-test-results-$timestamp.csv" 