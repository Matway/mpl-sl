# Copyright (C) 2021 Matway Burkow
#
# This repository and all its contents belong to Matway Burkow (referred here and below as "the owner").
# The content is for demonstration purposes only.
# It is forbidden to use the content or any part of it for any purpose without explicit permission from the owner.
# By contributing to the repository, contributors acknowledge that ownership of their work transfers to the owner.

"shell32Private" use

shell32Internal: {
  CSIDL_APPDATA: [0x001A];

  SHGFP_TYPE_CURRENT: [0]; # current value for user, verify it exists
  SHGFP_TYPE_DEFAULT: [1]; # default value, may not exist

  # shell32.Lib should be included for these functions
  SHGetFolderPathW: @SHGetFolderPathW;
};

shell32: [shell32Internal];
