# Test API endpoints

$baseUrl = "http://localhost:3001/api"

# First, try to register the user
Write-Host "Registering user..."
$registerBody = @{
    full_name = "Admin User BlueMoon"
    email = "ad10@bluemoon.com"
    password = "thisshouldbesafe"
    phone_number = "0987654321"
    status = "active"
} | ConvertTo-Json

try {
    $registerResponse = Invoke-RestMethod -Uri "$baseUrl/auth/staff/register" -Method POST -ContentType "application/json" -Body $registerBody
    Write-Host "Registration successful:"
    Write-Host ($registerResponse | ConvertTo-Json -Depth 3)
} catch {
    Write-Host "Registration failed or user already exists:"
    Write-Host $_.Exception.Message
}

Write-Host "`n---`n"

# Now try to login
Write-Host "Logging in..."
$loginBody = @{
    email = "ad10@bluemoon.com"
    password = "thisshouldbesafe"
} | ConvertTo-Json

try {
    $loginResponse = Invoke-RestMethod -Uri "$baseUrl/auth/staff/login" -Method POST -ContentType "application/json" -Body $loginBody
    Write-Host "Login successful:"
    Write-Host ($loginResponse | ConvertTo-Json -Depth 3)
} catch {
    Write-Host "Login failed:"
    Write-Host $_.Exception.Message
    
    # Try to get more details
    if ($_.Exception.Response) {
        $reader = New-Object System.IO.StreamReader($_.Exception.Response.GetResponseStream())
        $responseBody = $reader.ReadToEnd()
        Write-Host "Response body: $responseBody"
    }
} 