# Copyright (c) 2014 BPS Co., Ltd.
# All rights reserved.

CMS_FIND_PACKAGE(CTDRM_CLIENT cypherguard-client)

include (FindPackageHandleStandardArgs)
FIND_PACKAGE_HANDLE_STANDARD_ARGS(CypherGuardClientSDK
                                  REQUIRED_VARS
                                  CTDRM_CLIENT_INCLUDE_DIR
                                  CTDRM_CLIENT_LIBRARY_DIR
                                  VERSION_VAR
                                  CTDRM_CLIENT_VERSION_STRING)
mark_as_advanced (CTDRM_CLIENT_INCLUDE_DIR
                  CTDRM_CLIENT_LIBRARY_DIR)
