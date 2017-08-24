# Abdulaziz Albani Awesome Script :)

Menu

#Menu function to let the user choose what function to run
Function Menu{
echo "Welcom to My Script:
Enter 1 for Host Survay
Enter 2 for Directory files Hashes
Enter 3 for Search for a strong in a file
Enter 4 to  check the system services
Enter 5 to Exit"

$MenuOption = Read-Host -Prompt "Please enter your option followed by Enter "

#if-statment to run the choosen function
if($MenuOption -eq 1){
    echo "*************************************************"
    survey
}elseif($MenuOption -eq 2){
# hashdir
    echo "*************************************************"
    $outputFile = Read-Host -Prompt "Enter D/d for defult output file or enter a path for a file "
#if-statement to decide what output file to give the function
    if($outputFile -eq "d" -or $outputFile -eq "D"){
    hashdir
    }else{
    hashdir -OutputFile $outputFile
    }
}elseif($MenuOption -eq 3){
    echo "*************************************************"
    String-Greper
}elseif($MenuOption -eq 4){
    echo "*************************************************"
    checkServices
}elseif($MenuOption -eq 5){
    echo "*************************************************"
    echo "Goodbye !!"
    exit
}
}

#Survey function will print the host info, process list, open sockets
Function survey{

#mandatory parameter for file path
param(
[Parameter(Mandatory=$true,HelpMessage="Enter a file path to store the output in")][string]$OutputFile)

#if-statment to check if the file exist
if(Test-Path $OutputFile){
#get the time & date
    Get-Date > $OutputFile
#get system information
    systeminfo >> $OutputFile
#get process list sorted by session number
    Get-Process | Sort-Object -Descending -Property si  >> $OutputFile
#get open sockets list
    netstat -ano >> $OutputFile

}else{
    echo "File does not exist !!"
}

echo "*************************************************"
Menu
}

#hashdir function will get content of a directory then generate and save a hash of each file in the directory
function hashdir{
param(
[Parameter(Mandatory=$true,HelpMessage="Enter a directory path ")][string]$DirectoryPath,
[string]$OutputFile= "C:\Users\abani\Desktop\test.txt"
     )

#if-statment to check if the directory exist
if(Test-Path $DirectoryPath){
     Get-ChildItem -Path $DirectoryPath -Recurse | Get-FileHash -Algorithm MD5 > $OutputFile
}else{
echo "Directory does not exist !!"
}   

echo "*************************************************"
Menu
}

#String-Greper function will search for a given string within a given file
function String-Greper{
param(
[Parameter(Mandatory=$true,HelpMessage="Enter a string to search for")][string]$myStr,
[Parameter(Mandatory=$true,HelpMessage="Enter a file path")][string]$fileName)

#if-statement to check if the file exist or not
if(Test-Path $fileName){

#to get the file content and save it in a variable
    $fileData = Get-Content $fileName

#if-statement to search within the file for a match
   if($fileData -cmatch $myStr){
        echo "Match in $fileName"
        }
       
   else{
        echo "String not find!!"
    }
  }
else{
     echo "File does not exist!!"
   }
echo "*************************************************"
Menu
}

#checkServices function will get the services hash and after 5 seconds will compare it to a new services hash
function checkServices{

#create a file wich has a list of services
Get-WmiObject -Class Win32_Service | fl Name, DisplayName,Description, StartMode, State, Status, PathName, ProcessID, @{Label="Running as"; Expression={$_.StartName}} | more > D:\services.txt
$ServicesFile  = "D:\services.txt"

#hash the services file and save it in the givin output file
$ServicesBaseLine = hashFile -filePath $ServicesFile
echo " Services hash is in the output file"

#Sleep for 5 seconds
    echo "Sleep for 10 Seconds :x"
    sleep -Seconds 10

#after the sleep get the services file data to a variable
#    $ServicesBaseLine = Get-Content -Path $outputFile

#current services hash
    Get-WmiObject -Class Win32_Service | fl Name, DisplayName,Description, StartMode, State, Status, PathName, ProcessID, @{Label="Running as"; Expression={$_.StartName}} | more > D:\tmp.txt
    $currentHash =hashFile -filePath D:\tmp.txt

#if-statement to compare stored services hash with the current services hash
if($ServicesBaseLine -eq $currentHash){
    echo "Services is checked and it's not changed ;)"
}else{
    echo "Services is changed !!! Allert"
}
    echo "*************************************************"
    Menu
}

#hashFile function will take a file, hash it (using SHA512) then return the hash
function hashFile{
param([string]$filePath)
return (Get-FileHash -Algorithm SHA512 -Path $filePath)
}
