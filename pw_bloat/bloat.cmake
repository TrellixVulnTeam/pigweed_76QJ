# Copyright 2021 The Pigweed Authors
#
# Licensed under the Apache License, Version 2.0 (the "License"); you may not
# use this file except in compliance with the License. You may obtain a copy of
# the License at
#
#     https://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
# WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
# License for the specific language governing permissions and limitations under
# the License.
include_guard(GLOBAL)

include($ENV{PW_ROOT}/pw_build/pigweed.cmake)

# This function creates a library under the specified ${NAME} which provides a
# a generated bloaty configuration for a given ELF file using
# pw_bloat.bloaty_config.
#
# Produces the ${OUTPUT} Bloaty McBloatface configuration file.
#
# Args:
#
#   NAME - name of the library to create
#   ELF_FILE - The input ELF file to process using pw_bloat.bloaty_config
#   OUTPUT - The output Bloaty McBloatface configuration file
function(pw_bloaty_config NAME)
  set(option_args)
  set(one_value_args ELF_FILE OUTPUT)
  set(multi_value_args)
  pw_parse_arguments_strict(pw_bloaty_config
      1 "${option_args}" "${one_value_args}" "${multi_value_args}"
  )

  if("${arg_ELF_FILE}" STREQUAL "")
    message(FATAL_ERROR
      "pw_bloaty_config requires an input ELF file in ELF_FILE. "
      "No ELF_FILE was listed for ${NAME}")
  endif()

  if("${arg_OUTPUT}" STREQUAL "")
    message(FATAL_ERROR
      "pw_bloaty_config requires an output config file in OUTPUT. "
      "No OUTPUT was listed for ${NAME}")
  endif()

  add_library(${NAME} INTERFACE)
  add_dependencies(${NAME} INTERFACE ${NAME}_generated_config)

  add_custom_command(
    COMMENT "Generating ${NAME}'s ${arg_OUTPUT} for ${arg_ELF_FILE}."
    COMMAND
       ${Python3_EXECUTABLE}
       "$ENV{PW_ROOT}/pw_bloat/py/pw_bloat/bloaty_config.py"
       ${arg_ELF_FILE} -o ${arg_OUTPUT} -l warning
    DEPENDS ${arg_ELF_FILE}
    OUTPUT ${arg_OUTPUT} POST_BUILD
  )
  add_custom_target(${NAME}_generated_config
    DEPENDS ${arg_OUTPUT}
  )
endfunction()
