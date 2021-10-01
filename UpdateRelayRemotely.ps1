$parameters = @{
    ComputerName = "EDMSIIS"
    
    FilePath = "UpdateRelay.ps1"
  }
  Invoke-Command @parameters
