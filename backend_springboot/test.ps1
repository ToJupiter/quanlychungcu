# BlueMoon API Test Script - ~100 Cases
# Set base URL
$baseUrl = "http://localhost:3001/api"

# Helper: Login and get token
function Get-AuthToken($email, $password) {
    $loginBody = @{
        email = $email
        password = $password
    } | ConvertTo-Json
    $resp = Invoke-RestMethod -Uri "$baseUrl/auth/staff/login" -Method Post -Body $loginBody -ContentType "application/json"
    return $resp.token
}

# 3. Admin Login
$adminToken = Get-AuthToken "admin@bluemoon.com" "admin123"

# 4. Accountant Login
$accToken = Get-AuthToken "accountant@bluemoon.com" "accountant123"

# 5. Add Staff (loop to create 10 staff)
for ($i=1; $i -le 10; $i++) {
    $staffBody = @{
        full_name = "Staff User $i"
        email = "staff$i@example.com"
        phone_number = "09000000{0:D3}" -f $i
        password = "StaffPass123!"
        status = "active"
        roles = 1
    } | ConvertTo-Json
    try {
        Invoke-RestMethod -Uri "$baseUrl/staff" -Method Post -Body $staffBody -ContentType "application/json" -Headers @{Authorization = "Bearer $adminToken"}
    } catch { Write-Host "Staff $i exists or error" }
}

# 6. Get Staff List
$staffList = Invoke-RestMethod -Uri "$baseUrl/staff" -Headers @{Authorization = "Bearer $adminToken"}

# 7. Get Each Staff By Id
foreach ($staff in $staffList) {
    try {
        Invoke-RestMethod -Uri "$baseUrl/staff/$($staff.staff_id)" -Headers @{Authorization = "Bearer $adminToken"}
    } catch { Write-Host "Error getting staff $($staff.email)" }
}

# 8. Update Staff Status (toggle)
foreach ($staff in $staffList) {
    $statusBody = @{ status = "inactive" } | ConvertTo-Json
    try {
        Invoke-RestMethod -Uri "$baseUrl/staff/$($staff.staff_id)/status" -Method Patch -Body $statusBody -ContentType "application/json" -Headers @{Authorization = "Bearer $adminToken"}
    } catch { Write-Host "Error updating status for $($staff.email)" }
}

# 9. Reset Staff Password
foreach ($staff in $staffList) {
    $resetBody = @{ password = "ResetPass123!" } | ConvertTo-Json
    try {
        Invoke-RestMethod -Uri "$baseUrl/staff/$($staff.staff_id)/reset-password" -Method Patch -Body $resetBody -ContentType "application/json" -Headers @{Authorization = "Bearer $adminToken"}
    } catch { Write-Host "Error resetting password for $($staff.email)" }
}

# 10. Delete Staff (except admin/accountant)
foreach ($staff in $staffList) {
    if ($staff.email -notin @("admin@bluemoon.com", "accountant@bluemoon.com")) {
        try {
            Invoke-RestMethod -Uri "$baseUrl/staff/$($staff.staff_id)" -Method Delete -Headers @{Authorization = "Bearer $adminToken"}
        } catch { Write-Host "Error deleting $($staff.email)" }
    }
}

# 11. Add 10 Apartments
for ($i=1; $i -le 10; $i++) {
    $aptBody = @{
        apartment_number = "A10$i"
        area = 80 + $i
        status = "occupied"
    } | ConvertTo-Json
    try {
        Invoke-RestMethod -Uri "$baseUrl/management/apartments" -Method Post -Body $aptBody -ContentType "application/json" -Headers @{Authorization = "Bearer $adminToken"}
    } catch { Write-Host "Apartment $i exists or error" }
}

# 12. Get Apartment List
$aptList = Invoke-RestMethod -Uri "$baseUrl/management/apartments" -Headers @{Authorization = "Bearer $adminToken"}

# 13. Add 10 Households (1 per apartment)
$householdIds = @()
for ($i=0; $i -lt 10; $i++) {
    $householdBody = @{
        apartment_id = $aptList[$i].apartment_id
        move_in_date = "2024-06-01"
        head_resident_id = ""
        residents = @()
        vehicles = @()
    } | ConvertTo-Json
    try {
        $hhResp = Invoke-RestMethod -Uri "$baseUrl/management/households" -Method Post -Body $householdBody -ContentType "application/json" -Headers @{Authorization = "Bearer $adminToken"}
        $householdIds += $hhResp.household_id
    } catch { Write-Host "Household $i exists or error" }
}

# 14. Add 5 Residents to each Household
foreach ($hhId in $householdIds) {
    for ($j=1; $j -le 5; $j++) {
        $residentBody = @{
            household_id = $hhId
            full_name = "Resident $j of $hhId"
            date_of_birth = "1990-01-0$j"
            cccd_number = "01234567$($j+1000)"
            role_in_household = if ($j -eq 1) { "Head" } else { "Member" }
        } | ConvertTo-Json
        try {
            Invoke-RestMethod -Uri "$baseUrl/management/households/$hhId/residents" -Method Post -Body $residentBody -ContentType "application/json" -Headers @{Authorization = "Bearer $adminToken"}
        } catch { Write-Host "Resident $j for $hhId exists or error" }
    }
}

# 15. Add 2 Vehicles to each Household
foreach ($hhId in $householdIds) {
    for ($k=1; $k -le 2; $k++) {
        $vehicleBody = @{
            household_id = $hhId
            plate_number = "30A-1$($k)0$($hhId.Substring(0,2))"
            vehicle_type = if ($k -eq 1) { "Car" } else { "Motorbike" }
            registration_date = "2024-06-01"
        } | ConvertTo-Json
        try {
            Invoke-RestMethod -Uri "$baseUrl/management/households/$hhId/vehicles" -Method Post -Body $vehicleBody -ContentType "application/json" -Headers @{Authorization = "Bearer $adminToken"}
        } catch { Write-Host "Vehicle $k for $hhId exists or error" }
    }
}

# 16. Add 3 Payments to each Household
foreach ($hhId in $householdIds) {
    for ($m=1; $m -le 3; $m++) {
        $paymentBody = @{
            household_id = $hhId
            payment_type = if ($m -eq 1) { "Maintenance" } elseif ($m -eq 2) { "Water" } else { "Electricity" }
            amount = 1000000 * $m
            due_date = "2024-07-0$m"
            payment_date = "2024-06-16"
            status = if ($m % 2 -eq 0) { "paid" } else { "unpaid" }
            notes = "Test payment $m for $hhId"
        } | ConvertTo-Json
        try {
            Invoke-RestMethod -Uri "$baseUrl/finance/payments" -Method Post -Body $paymentBody -ContentType "application/json" -Headers @{Authorization = "Bearer $adminToken"}
        } catch { Write-Host "Payment $m for $hhId exists or error" }
    }
}

# 17. Get Analytics Dashboard
Invoke-RestMethod -Uri "$baseUrl/analytics/dashboard" -Headers @{Authorization = "Bearer $adminToken"}

Write-Host "~100 API test cases executed."