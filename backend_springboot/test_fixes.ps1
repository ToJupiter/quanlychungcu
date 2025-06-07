# Test script for verifying the Spring Boot backend fixes

$baseUrl = "http://localhost:3001/api"

# Test user credentials
$loginBody = @{
    email = "ad10@bluemoon.com"
    password = "thisshouldbesafe"
} | ConvertTo-Json

Write-Host "=== Testing Login ==="
try {
    $loginResponse = Invoke-RestMethod -Uri "$baseUrl/auth/staff/login" -Method POST -ContentType "application/json" -Body $loginBody
    $token = $loginResponse.token
    Write-Host "✅ Login successful"
    Write-Host "Token: $token"
} catch {
    Write-Host "❌ Login failed: $($_.Exception.Message)"
    exit 1
}

# Set headers with token
$headers = @{
    'Authorization' = "Bearer $token"
    'Content-Type' = 'application/json'
}

Write-Host "`n=== Testing Household List (Fixed) ==="
try {
    $householdsResponse = Invoke-RestMethod -Uri "$baseUrl/management/households" -Method GET -Headers $headers
    Write-Host "✅ Households endpoint works"
    Write-Host "Number of households: $($householdsResponse.Count)"
    
    if ($householdsResponse.Count -gt 0) {
        $firstHousehold = $householdsResponse[0]
        Write-Host "First household apartment number: $($firstHousehold.apartment_number)"
        Write-Host "First household head name: $($firstHousehold.head_full_name)"
        Write-Host "First household apartment area: $($firstHousehold.apartment_area)"
    }
} catch {
    Write-Host "❌ Households test failed: $($_.Exception.Message)"
}

Write-Host "`n=== Testing Financial Summary (Fixed) ==="
try {
    $startDate = "2025-01-01"
    $endDate = "2025-12-31"
    $financialResponse = Invoke-RestMethod -Uri "$baseUrl/finance/reports/financial-summary?startDate=$startDate&endDate=$endDate" -Method GET -Headers $headers
    Write-Host "✅ Financial summary endpoint works"
    Write-Host "Total collected: $($financialResponse.totalCollected)"
    Write-Host "Total due in period: $($financialResponse.totalDueInPeriod)"
    Write-Host "Total outstanding unpaid: $($financialResponse.totalOutstandingUnpaid)"
} catch {
    Write-Host "❌ Financial summary test failed: $($_.Exception.Message)"
}

Write-Host "`n=== Testing New Dashboard Stats ==="
try {
    $dashboardResponse = Invoke-RestMethod -Uri "$baseUrl/finance/dashboard/stats" -Method GET -Headers $headers
    Write-Host "✅ Dashboard stats endpoint works"
    Write-Host "Total revenue: $($dashboardResponse.totalRevenue)"
    Write-Host "Total due: $($dashboardResponse.totalDue)"
    Write-Host "Total payments: $($dashboardResponse.totalPayments)"
    Write-Host "Paid payments: $($dashboardResponse.paidPayments)"
    Write-Host "Unpaid payments: $($dashboardResponse.unpaidPayments)"
} catch {
    Write-Host "❌ Dashboard stats test failed: $($_.Exception.Message)"
}

Write-Host "`n=== Testing Payment List ==="
try {
    $paymentsResponse = Invoke-RestMethod -Uri "$baseUrl/finance/payments" -Method GET -Headers $headers
    Write-Host "✅ Payments endpoint works"
    Write-Host "Number of payments: $($paymentsResponse.Count)"
    
    if ($paymentsResponse.Count -gt 0) {
        $firstPayment = $paymentsResponse[0]
        Write-Host "First payment amount: $($firstPayment.amount)"
        Write-Host "First payment status: $($firstPayment.status)"
        Write-Host "First payment apartment: $($firstPayment.apartment_number)"
    }
} catch {
    Write-Host "❌ Payments test failed: $($_.Exception.Message)"
}

Write-Host "`n=== Tests Complete ===" 