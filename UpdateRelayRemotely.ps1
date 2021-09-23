$parameters = @{
    ComputerName = "EDMSDUTIL3","EDMSIIS","EDMSFISP1","EDMSIISP2","EDMSPRCP1","EDMSRDSP2","EDMSRDSP3","EDMSRDSP4","EDMSIISP3","EDMSIISP1"
    FilePath = "UpdateRelay.ps1"
  }
  Invoke-Command @parameters
