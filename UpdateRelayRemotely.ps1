$parameters = @{
    ComputerName = "EDMSDUTIL3","EDMSIIS","EDMSFISP1","EDMSFISP1","EDMSPRCP1","EDMSRDSP2","EDMSRDSP3","EDMSRDSP4","EDMSIISP3"
    FilePath = "UpdateRelay.ps1"
  }
  Invoke-Command @parameters
