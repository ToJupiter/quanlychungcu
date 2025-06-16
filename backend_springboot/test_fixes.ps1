# Comprehensive API Test Script for BlueMoon Apartment Management System
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
        timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    }
}

# UC-001 to UC-005: User Management Tests
$tests = @(
    @{
        testName = "TC001_RegisterAdmin"
        testObject = "Đăng ký"
        description = "Kiểm tra đăng ký user admin mới"
        method = "POST"
        endpoint = "/auth/register"
        body = @{
            email = "admin@bluemoon.com"
            password = "Admin@123"
            fullName = "Admin User"
            role = "ADMIN"
        }
        expectedStatus = "201 Created"
    },
    @{
        testName = "TC002_RegisterDuplicateAdmin"
        testObject = "Đăng ký"
        description = "Kiểm tra đăng ký trùng email"
        method = "POST"
        endpoint = "/auth/register"
        body = @{
            email = "admin@bluemoon.com"
            password = "Admin@123"
            fullName = "Admin User 2"
            role = "ADMIN"
        }
        expectedStatus = "400 Bad Request"
    },
    @{
        testName = "TC003_LoginAdmin"
        testObject = "Đăng nhập"
        description = "Kiểm tra đăng nhập admin hợp lệ"
        method = "POST"
        endpoint = "/auth/login"
        body = @{
            email = "admin@bluemoon.com"
            password = "Admin@123"
        }
        expectedStatus = "200 OK"
    }
)

# Execute initial tests and store token
foreach ($test in $tests) {
    Test-Endpoint @test
}

# Get token from successful login
$token = ($results | Where-Object { $_.testName -eq "TC003_LoginAdmin" -and $_.status -eq "PASS" }).actualOutput.token
$authHeaders = @{
    "Content-Type" = "application/json"
    "Authorization" = "Bearer $token"
}

# UC-006 to UC-009: Household Management Tests
$householdTests = @(
    @{
        testName = "TC004_CreateHousehold"
        testObject = "Quản lý hộ gia đình"
        description = "Tạo hộ gia đình mới"
        method = "POST"
        endpoint = "/households"
        body = @{
            apartmentNumber = "101"
            area = 100
            ownerName = "Nguyễn Văn A"
        }
        expectedStatus = "201 Created"
    },
    @{
        testName = "TC005_GetAllHouseholds"
        testObject = "Quản lý hộ gia đình"
        description = "Lấy danh sách hộ gia đình"
        method = "GET"
        endpoint = "/households"
        expectedStatus = "200 OK"
    },
    @{
        testName = "TC006_AddHouseholdMember"
        testObject = "Quản lý thành viên"
        description = "Thêm thành viên hộ gia đình"
        method = "POST"
        endpoint = "/households/1/members"
        body = @{
            name = "Nguyễn Văn B"
            identityCard = "001122334455"
            relationship = "Con"
        }
        expectedStatus = "201 Created"
    }
)

# Execute household tests with auth headers
foreach ($test in $householdTests) {
    $test.headers = $authHeaders
    Test-Endpoint @test
}

# UC-010 to UC-011: Fee Management Tests
$feeTests = @(
    @{
        testName = "TC007_AddHouseholdFee"
        testObject = "Quản lý phí"
        description = "Thêm phí cho hộ gia đình"
        method = "POST"
        endpoint = "/households/1/fees"
        body = @{
            feeType = "ELECTRIC"
            amount = 500000
            dueDate = "2024-04-30"
        }
        expectedStatus = "201 Created"
    },
    @{
        testName = "TC008_GetHouseholdFees"
        testObject = "Quản lý phí"
        description = "Lấy danh sách phí của hộ"
        method = "GET"
        endpoint = "/households/1/fees"
        expectedStatus = "200 OK"
    }
)

# Execute fee tests with auth headers
foreach ($test in $feeTests) {
    $test.headers = $authHeaders
    Test-Endpoint @test
}

# UC-012 to UC-013: Vehicle Management Tests
$vehicleTests = @(
    @{
        testName = "TC009_AddHouseholdVehicle"
        testObject = "Quản lý phương tiện"
        description = "Thêm phương tiện cho hộ"
        method = "POST"
        endpoint = "/households/1/vehicles"
        body = @{
            type = "CAR"
            licensePlate = "30A-12345"
            brand = "Toyota"
            model = "Camry"
        }
        expectedStatus = "201 Created"
    },
    @{
        testName = "TC010_GetHouseholdVehicles"
        testObject = "Quản lý phương tiện"
        description = "Lấy danh sách phương tiện"
        method = "GET"
        endpoint = "/households/1/vehicles"
        expectedStatus = "200 OK"
    }
)

# Execute vehicle tests with auth headers
foreach ($test in $vehicleTests) {
    $test.headers = $authHeaders
    Test-Endpoint @test
}

# UC-014: Analytics and Reports Tests
$reportTests = @(
    @{
        testName = "TC011_GetFinancialReport"
        testObject = "Báo cáo thống kê"
        description = "Lấy báo cáo tài chính"
        method = "GET"
        endpoint = "/reports/financial"
        expectedStatus = "200 OK"
    },
    @{
        testName = "TC012_GetHouseholdStats"
        testObject = "Báo cáo thống kê"
        description = "Lấy thống kê hộ gia đình"
        method = "GET"
        endpoint = "/reports/households"
        expectedStatus = "200 OK"
    }
)

# Execute report tests with auth headers
foreach ($test in $reportTests) {
    $test.headers = $authHeaders
    Test-Endpoint @test
}

# Export results
$timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
$jsonFile = "bluemoon-comprehensive-test-results-$timestamp.json"
$csvFile = "bluemoon-comprehensive-test-results-$timestamp.csv"

# Export to JSON
$results | ConvertTo-Json -Depth 10 | Out-File $jsonFile

# Export to CSV
$csvHeader = "Test Name,Test Object,Description,Input,Expected Output,Actual Output,Status,Timestamp"
$csvContent = $results | ForEach-Object {
    "{0},{1},{2},{3},{4},{5},{6},{7}" -f `
        $_.testName,
        $_.testObject,
        $_.description,
        ($_.input -replace ',', ';'),
        $_.expectedOutput,
        ($_.actualOutput -replace ',', ';'),
        $_.status,
        $_.timestamp
}

$csvHeader | Out-File $csvFile
$csvContent | Add-Content $csvFile

Write-Host "Test results exported to:"
Write-Host "JSON: $jsonFile"
Write-Host "CSV: $csvFile"

# Summary
$totalTests = $results.Count
$passedTests = ($results | Where-Object { $_.status -eq "PASS" }).Count
$failedTests = $totalTests - $passedTests

Write-Host "`nTest Summary:"
Write-Host "Total Tests: $totalTests"
Write-Host "Passed: $passedTests"
Write-Host "Failed: $failedTests"
Write-Host "Success Rate: $([math]::Round(($passedTests/$totalTests)*100,2))%" 