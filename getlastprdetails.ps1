param(
    [parameter(Mandatory = $true)]
    [String]$token,
    [parameter(Mandatory = $true)]
    [String]$repoName
)

$commitMessage = git show -s --format=%s $env:GitHash
Write-Host "message : $commitMessage"
$messageArray = $commitMessage.ToString().Split("#")
$shouldIncrement="no"
if ($messageArray.Length -eq 2)
{
    $prNumber = $messageArray[1].TrimEnd(")")
    Write-Host "prNumber : $prNumber"
    $isPrNumberNumeric = $prNumber -match "^[\d\.]+$"
    Write-Host "isPrNumberNumeric : $isPrNumberNumeric"
    if ($isPrNumberNumeric -eq $true)
    {
        $prDetails = Invoke-RestMethod -Uri "https://api.github.com/repos/$repoName/pulls/$prNumber" -Headers @{ Authorization = "Bearer $token" }
        $branch = $prDetails.head.ref
        Write-Host "branch : $branch"              
        if($env:EventName -eq "push")
        {
            echo PR_BRANCH=$branch >> $env:GITHUB_OUTPUT
            $shouldIncrement="yes"
        }
    }
}
echo AutoIncrement=$shouldIncrement >> $env:GITHUB_OUTPUT