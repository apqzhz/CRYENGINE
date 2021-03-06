# Copy required additional files from 3rdparty to the binary folder
set(DEPLOY_FILES  CACHE INTERNAL "List of files to deploy before running")

set (BinaryFileList_Win64
	${SDK_DIR}/XT_13_4/bin_vc14/*.dll
	${SDK_DIR}/Mono/bin/x64/mono-2.0.dll

	${SDK_DIR}/Brofiler/ProfilerCore64.dll

	${SDK_DIR}/audio/oculus/wwise/bin/plugins/OculusSpatializer.dll

	${SDK_DIR}/OpenVR/bin/win64/*.*

	${SDK_DIR}/OSVR/dll/*.dll

	${SDK_DIR}/Qt/5.6/msvc2015_64/Qt/bin/*.dll

	"${SDK_DIR}/Microsoft Windows SDK/10/Debuggers/x64/dbghelp.dll"
	"${SDK_DIR}/Microsoft Windows SDK/10/bin/x64/d3dcompiler_47.dll"

	${SDK_DIR}/CrashRpt/1403/bin/x64/CrashSender1403.exe
	${SDK_DIR}/CrashRpt/1403/bin/x64/crashrpt_lang.ini

	)

set (BinaryFileList_Win32
	${SDK_DIR}/Brofiler/ProfilerCore32.dll
	${SDK_DIR}/Mono/bin/x86/mono-2.0.dll
	"${SDK_DIR}/Microsoft Windows SDK/10/Debuggers/x86/dbghelp.dll"
	"${SDK_DIR}/Microsoft Windows SDK/10/bin/x86/d3dcompiler_47.dll"

	${SDK_DIR}/CrashRpt/1403/bin/CrashSender1403.exe
	${SDK_DIR}/CrashRpt/1403/bin/crashrpt_lang.ini

	)

set (BinaryFileList_LINUX64
	${SDK_DIR}/ncurses/lib/libncursesw.so.6
	)

macro(deploy_runtime_file source destination)
	list(APPEND DEPLOY_FILES ${source})
	list(APPEND DEPLOY_FILES ${destination})
	set(DEPLOY_FILES "${DEPLOY_FILES}" CACHE INTERNAL "List of files to deploy before running")
endmacro()

macro(deploy_runtime_files fileexpr)
	file(GLOB FILES_TO_COPY ${fileexpr})
	foreach(FILE_PATH ${FILES_TO_COPY})
		get_filename_component(FILE_NAME ${FILE_PATH} NAME)

		# If another argument was passed files are deployed to the subdirectory
		if (${ARGC} GREATER 1)
			deploy_runtime_file(${FILE_PATH} ${CMAKE_RUNTIME_OUTPUT_DIRECTORY}/${ARGV1}/${FILE_NAME})
			install(FILES ${FILE_PATH} DESTINATION bin/${ARGV1})
		else ()
			deploy_runtime_file(${FILE_PATH} ${CMAKE_RUNTIME_OUTPUT_DIRECTORY}/${FILE_NAME})
			install(FILES ${FILE_PATH} DESTINATION bin)
		endif ()
	endforeach()
endmacro()

macro(deploy_runtime_dir dir output_dir)
	file(GLOB_RECURSE FILES_TO_COPY RELATIVE ${CMAKE_CURRENT_SOURCE_DIR}/${dir} ${CMAKE_CURRENT_SOURCE_DIR}/${dir}/*)

	foreach(FILE_NAME ${FILES_TO_COPY})
		set(FILE_PATH ${CMAKE_CURRENT_SOURCE_DIR}/${dir}/${FILE_NAME})

		deploy_runtime_file(${FILE_PATH} ${CMAKE_RUNTIME_OUTPUT_DIRECTORY}/${output_dir}/${FILE_NAME})
	endforeach()

	install(DIRECTORY ${dir} DESTINATION bin/${output_dir})
endmacro()

macro(copy_binary_files_to_target)
	set( file_list_name "BinaryFileList_${BUILD_PLATFORM}" )
	get_property( BINARY_FILE_LIST VARIABLE PROPERTY ${file_list_name} )
	deploy_runtime_files("${BINARY_FILE_LIST}")
  
	if (ORBIS)
		deploy_runtime_files(${SDK_DIR}/Orbis/target/sce_module/*.prx app/sce_module)
	endif()

	if (WIN64) 
		deploy_runtime_files(${SDK_DIR}/Qt/5.6/msvc2015_64/Qt/plugins/platforms/*.dll platforms)
		deploy_runtime_files(${SDK_DIR}/Qt/5.6/msvc2015_64/Qt/plugins/imageformats/*.dll imageformats)

		deploy_runtime_files("${SDK_DIR}/Microsoft Visual Studio Compiler/14.0/redist/x64/**/*.dll")
	elseif(WIN32)
		deploy_runtime_files("${SDK_DIR}/Microsoft Visual Studio Compiler/14.0/redist/x86/**/*.dll")
	endif ()

	if(WIN32 AND OPTION_CRYMONO)
		# Deploy mono runtime
		# This does not work as intended if CryEngine_DIR is not equal to CMAKE_SOURCE_DIR and should be rethought
		deploy_runtime_dir(Code/SDKs/Mono ../../Engine/Mono)
	endif()

	if(DEPLOY_FILES)
		set(DEPLOY_DESTINATIONS)

		list(LENGTH DEPLOY_FILES deployFilesCount)
		math(EXPR idxRangeEnd "${deployFilesCount} - 1")

		foreach(idx RANGE 0 ${idxRangeEnd} 2)
			math(EXPR idxIncr "${idx} + 1")
			list(GET DEPLOY_FILES ${idx} source)
			list(GET DEPLOY_FILES ${idxIncr} destination)

			add_custom_command(OUTPUT ${destination} 
				COMMAND ${CMAKE_COMMAND} -DSOURCE=${source} -DDESTINATION=${destination} -P ${CryEngine_DIR}/Tools/CMake/deploy_runtime_files.cmake
				COMMENT "Deploying ${source}"
				DEPENDS ${source})

			list(APPEND DEPLOY_DESTINATIONS ${destination})
		endforeach(idx)

		add_custom_target(deployrt ALL DEPENDS ${DEPLOY_DESTINATIONS})
	endif()
endmacro()


