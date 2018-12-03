"ole32" module
"control" includeModule
"ole32Private" useModule

ole32: {
  # Ole32.Lib should be included for these functions
  CoInitialize: @CoInitialize;
  CoUninitialize: @CoUninitialize;
};
