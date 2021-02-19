# Copyright (C) 2021 Matway Burkow
#
# This repository and all its contents belong to Matway Burkow (referred here and below as "the owner").
# The content is for demonstration purposes only.
# It is forbidden to use the content or any part of it for any purpose without explicit permission from the owner.
# By contributing to the repository, contributors acknowledge that ownership of their work transfers to the owner.

"ole32Private" use

ole32Internal: {
  # Ole32.Lib should be included for these functions
  CoInitialize: @CoInitialize;
  CoUninitialize: @CoUninitialize;
};

ole32: [ole32Internal];
