"shell32" module
"control" useModule
"shell32Private" useModule

shell32: {
  CSIDL_APPDATA: [0x001A] func;

  SHGFP_TYPE_CURRENT: [0] func;   # current value for user, verify it exists
  SHGFP_TYPE_DEFAULT: [1] func;   # default value, may not exist

  # shell32.Lib should be included for these functions
  SHGetFolderPathW: @SHGetFolderPathW;
};
