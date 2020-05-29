"shell32Private" use

shell32Internal: {
  CSIDL_APPDATA: [0x001A];

  SHGFP_TYPE_CURRENT: [0];   # current value for user, verify it exists
  SHGFP_TYPE_DEFAULT: [1];   # default value, may not exist

  # shell32.Lib should be included for these functions
  SHGetFolderPathW: @SHGetFolderPathW;
};

shell32: [shell32Internal];
