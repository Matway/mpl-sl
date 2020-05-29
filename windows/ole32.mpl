"ole32Private" use

ole32Internal: {
  # Ole32.Lib should be included for these functions
  CoInitialize: @CoInitialize;
  CoUninitialize: @CoUninitialize;
};

ole32: [ole32Internal];
