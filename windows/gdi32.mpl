# Copyright (C) 2021 Matway Burkow
#
# This repository and all its contents belong to Matway Burkow (referred here and below as "the owner").
# The content is for demonstration purposes only.
# It is forbidden to use the content or any part of it for any purpose without explicit permission from the owner.
# By contributing to the repository, contributors acknowledge that ownership of their work transfers to the owner.

"gdi32Private" use

gdi32Internal: {
  PIXELFORMATDESCRIPTOR: @PIXELFORMATDESCRIPTOR;

  # Gdi32.Lib should be included for these functions
  ChoosePixelFormat: @ChoosePixelFormat;
  SetPixelFormat: @SetPixelFormat;
  SwapBuffers: @SwapBuffers;
};

gdi32: [gdi32Internal];
