# Script to create test data for testing the Spring Boot backend

$baseUrl = "http://localhost:3001/api"

# Login first
$loginBody = @{
    email = "ad10@bluemoon.com"
    password = "thisshouldbesafe"
} | ConvertTo-Json

Write-Host "=== Logging in ==="
try {
    $loginResponse = Invoke-RestMethod -Uri "$baseUrl/auth/staff/login" -Method POST -ContentType "application/json" -Body $loginBody
    $token = $loginResponse.token
    Write-Host "✅ Login successful"
} catch {
    Write-Host "❌ Login failed: $($_.Exception.Message)"
    exit 1
}

$headers = @{
    'Authorization' = "Bearer $token"
    'Content-Type' = 'application/json'
}

Write-Host "`n=== Creating Test Apartments ==="
$apartments = @(
    @{ apartment_number = "A101"; area = 75.5; status = "vacant" },
    @{ apartment_number = "A102"; area = 80.0; status = "vacant" },
    @{ apartment_number = "B201"; area = 90.5; status = "vacant" }
)

foreach ($apt in $apartments) {
    try {
        $aptBody = $apt | ConvertTo-Json
        $response = Invoke-RestMethod -Uri "$baseUrl/management/apartments" -Method POST -Headers $headers -Body $aptBody
        Write-Host "✅ Created apartment $($apt.apartment_number) with ID: $($response.apartment_id)"
    } catch {
        Write-Host "⚠️ Apartment $($apt.apartment_number) might already exist: $($_.Exception.Message)"
    }
}

Write-Host "`n=== Creating Test Households ==="
# First get apartments to use their IDs
try {
    $apartmentsResponse = Invoke-RestMethod -Uri "$baseUrl/management/apartments" -Method GET -Headers $headers
    Write-Host "Found $($apartmentsResponse.Count) apartments"
    
    $households = @(
        @{ 
            apartment_id = $apartmentsResponse[0].apartment_id
            head_full_name = "Nguyen Van A"
            head_date_of_birth = "1980-01-15"
            head_cccd_number = "123456789012"
            move_in_date = "2024-01-01"
        },
        @{ 
            apartment_id = $apartmentsResponse[1].apartment_id
            head_full_name = "Tran Thi B"
            head_date_of_birth = "1985-05-20"
            head_cccd_number = "987654321098"
            move_in_date = "2024-02-01"
        }
    )
    
    foreach ($household in $households) {
        try {
            $householdBody = $household | ConvertTo-Json
            $response = Invoke-RestMethod -Uri "$baseUrl/management/households" -Method POST -Headers $headers -Body $householdBody
            Write-Host "✅ Created household for apartment $($household.apartment_id)"
        } catch {
            Write-Host "⚠️ Household for apartment $($household.apartment_id) might already exist: $($_.Exception.Message)"
        }
    }
} catch {
    Write-Host "❌ Failed to create households: $($_.Exception.Message)"
}

Write-Host "`n=== Creating Test Payments ==="
# Get households to use their IDs
try {
    $householdsResponse = Invoke-RestMethod -Uri "$baseUrl/management/households" -Method GET -Headers $headers
    Write-Host "Found $($householdsResponse.Count) households"
    
    if ($householdsResponse.Count -ge 2) {
        $payments = @(
            @{
                household_id = $householdsResponse[0].household_id
                payment_type = "Service Fee"
                amount = 500000
                due_date = "2025-06-01"
                payment_date = "2025-06-05"
                status = "Paid"
            },
            @{
                household_id = $householdsResponse[0].household_id
                payment_type = "Parking Fee"
                amount = 200000
                due_date = "2025-06-01"
                payment_date = "2025-06-03"
                status = "Paid"
            },
            @{
                household_id = $householdsResponse[1].household_id
                payment_type = "Service Fee"
                amount = 500000
                due_date = "2025-06-01"
                status = "Unpaid"
            },
            @{
                household_id = $householdsResponse[1].household_id
                payment_type = "Water Bill"
                amount = 150000
                due_date = "2025-05-15"
                payment_date = "2025-05-20"
                status = "Paid"
            }
        )
        
        foreach ($payment in $payments) {
            try {
                $paymentBody = $payment | ConvertTo-Json
                $response = Invoke-RestMethod -Uri "$baseUrl/finance/payments" -Method POST -Headers $headers -Body $paymentBody
                Write-Host "✅ Created payment: $($payment.payment_type) - $($payment.amount) VND - Status: $($payment.status)"
            } catch {
                Write-Host "❌ Failed to create payment: $($_.Exception.Message)"
            }
        }
    }
} catch {
    Write-Host "❌ Failed to create payments: $($_.Exception.Message)"
}

Write-Host "`n=== Test Data Creation Complete ==="
Write-Host "You should now have:"
Write-Host "- 3 apartments"
Write-Host "- 2 households" 
Write-Host "- 4 payments (3 paid, 1 unpaid)"
Write-Host "- Total paid amount: 850,000 VND"
Write-Host "- Total unpaid amount: 500,000 VND" 