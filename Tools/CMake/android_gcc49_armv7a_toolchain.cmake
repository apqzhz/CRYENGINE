set(CMAKE_SYSTEM_NAME "Android")
set(ANDROID TRUE)

set(GCC_VERSION 4.9)

set(NDKROOT $ENV{NDKROOT})
set(CMAKE_ANDROID_API 23)
set(CMAKE_ARCH "armv7-a")
set(CMAKE_SYSTEM_PROCESSOR "armv7-a")

file(TO_CMAKE_PATH "${NDKROOT}" NDKROOT)

string(REPLACE "\\" "/" NDKROOT ${NDKROOT})

set(TOOLCHAIN_ROOT ${NDKROOT}/toolchains/arm-linux-androideabi-${GCC_VERSION}/prebuilt/windows-x86_64)
set(TOOLCHAIN_BIN ${TOOLCHAIN_ROOT}/bin)


set(CMAKE_C_COMPILER   ${TOOLCHAIN_BIN}/arm-linux-androideabi-gcc.exe)
set(CMAKE_CXX_COMPILER ${TOOLCHAIN_BIN}/arm-linux-androideabi-g++.exe)
set(CMAKE_ASM_COMPILER ${TOOLCHAIN_BIN}/arm-linux-androideabi-gcc.exe CACHE PATH "Assembler")
set(CMAKE_AR           ${TOOLCHAIN_BIN}/arm-linux-androideabi-gcc-ar.exe CACHE PATH "Archiver")
set(CMAKE_RANLIB       ${TOOLCHAIN_BIN}/arm-linux-androideabi-ranlib.exe CACHE PATH "Ranlib")
set(CMAKE_LINKER       ${TOOLCHAIN_BIN}/arm-linux-androideabi-ld.exe CACHE PATH "Linker")

set(CMAKE_SYSROOT ${NDKROOT}/platforms/android-${CMAKE_ANDROID_API}/arch-arm)
include_directories(${NDKROOT}/sources/android/support/include)
include_directories(${NDKROOT}/sources/android/native_app_glue)

# Include STL headers and lib
include_directories(${NDKROOT}/sources/cxx-stl/gnu-libstdc++/${GCC_VERSION}/include)
include_directories(${NDKROOT}/sources/cxx-stl/gnu-libstdc++/${GCC_VERSION}/include/backward)
include_directories(${NDKROOT}/sources/cxx-stl/gnu-libstdc++/${GCC_VERSION}/libs/armeabi-v7a/include)

# The static stl has to be linked to the shared object (!THERE MAY ONLY BE ONE SO using the static lib)
set(STL ${NDKROOT}/sources/cxx-stl/gnu-libstdc++/4.9/libs/armeabi-v7a/libgnustl_static.a)

# Change link rule for shared objects to link against the static stl
set(CMAKE_CXX_CREATE_SHARED_LIBRARY "<CMAKE_CXX_COMPILER> <CMAKE_SHARED_LIBRARY_CXX_FLAGS> <LANGUAGE_COMPILE_FLAGS> <LINK_FLAGS> <CMAKE_SHARED_LIBRARY_CREATE_CXX_FLAGS> <CMAKE_SHARED_LIBRARY_SONAME_CXX_FLAG><TARGET_SONAME> -o <TARGET> <OBJECTS> <LINK_LIBRARIES> \"${STL}\"" )
set(CMAKE_CXX_CREATE_SHARED_MODULE  "<CMAKE_CXX_COMPILER> <CMAKE_SHARED_LIBRARY_CXX_FLAGS> <LANGUAGE_COMPILE_FLAGS> <LINK_FLAGS> <CMAKE_SHARED_LIBRARY_CREATE_CXX_FLAGS> <CMAKE_SHARED_LIBRARY_SONAME_CXX_FLAG><TARGET_SONAME> -o <TARGET> <OBJECTS> <LINK_LIBRARIES> \"${STL}\"" )

set(DEFINES "-DANDROID -DDISABLE_IMPORTGL -D__ANDROID__ -D__ARM_ARCH_7A__ -D_LINUX -DLINUX -DLINUX32 -DCRY_MOBILE -D_HAS_C9X -D_PROFILE -DPROFILE -D_MT -D_DLL -DCRY_PLATFORM_ANDROID")
set(NOWARNS "-Wno-multichar -Wno-write-strings -Wno-narrowing")
set(CXXNOWARNS "-Wno-invalid-offsetof -Wno-conversion-null")

set(CMAKE_C_FLAGS "-Wall -Werror" CACHE STRING "c flags")
set(CMAKE_CXX_FLAGS "-Wall -Werror" CACHE STRING "c++ flags")
set(CMAKE_SHARED_LINKER_FLAGS "" CACHE STRING "linker flags")

set(CMAKE_C_FLAGS "-march=armv7-a -fpic ${NOWARNS} ${DEFINES}")
set(CMAKE_CXX_FLAGS "-fno-exceptions -fno-rtti -std=c++11 -fpic -std=gnu++11 -fpermissive -march=armv7-a -mfpu=neon -marm -mfloat-abi=softfp ${CXXNOWARNS} ${NOWARNS} ${DEFINES}")

include( CMakeForceCompiler )
CMAKE_FORCE_C_COMPILER( "${CMAKE_C_COMPILER}" GNU )
CMAKE_FORCE_CXX_COMPILER( "${CMAKE_CXX_COMPILER}" GNU )

set(OUTPUT_DIRECTORY "${CMAKE_SOURCE_DIR}/bin/android")
macro(configure_android_build)
	set(options DEBUGGABLE)
	set(oneValueArgs PACKAGE APP_NAME VERSION_CODE VERSION_NAME)
	set(multiValueArgs PERMISSIONS)
	cmake_parse_arguments(ANDROID "${options}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN})
	string(TOLOWER "${ANDROID_DEBUGGABLE}" ANDROID_DEBUGGABLE) 
	
	set(apk_folder "${CMAKE_BINARY_DIR}/${THIS_PROJECT}Launcher/apk_data")
	file(REMOVE_RECURSE ${apk_folder})
	file(MAKE_DIRECTORY ${apk_folder}/src)
	file(MAKE_DIRECTORY ${apk_folder}/lib/armeabi-v7a)
	file(MAKE_DIRECTORY ${apk_folder}/gen)
	file(MAKE_DIRECTORY ${apk_folder}/bin)
	file(MAKE_DIRECTORY ${apk_folder}/build)

		
	# TODO: implement process_android_java_files from waf compile rules

	#Generate APK manifest
	file(WRITE ${apk_folder}/AndroidManifest.xml 
		"<?xml version=\"1.0\" encoding=\"utf-8\"?>\n"
		"	<!-- BEGIN_INCLUDE(manifest) -->\n"
		"	<manifest xmlns:android=\"http://schemas.android.com/apk/res/android\"\n"
		"		package=\"${ANDROID_PACKAGE}\"\n"
		"		android:versionCode=\"${ANDROID_VERSION_CODE}\"\n"
		"		android:debuggable=\"${ANDROID_DEBUGGABLE}\"\n"
		"		android:versionName=\"${ANDROID_VERSION_CODE}\" >\n"
		"\n"
		"		<!-- This is the platform API where NativeActivity was introduced. -->\n"
		"		<uses-sdk android:minSdkVersion=\"${CMAKE_ANDROID_API_MIN}\" />\n"
		"\n"
		"		<!-- OpenGL ES 3.0 -->\n"
		"		<uses-feature android:glEsVersion=\"0x00030000\" android:required=\"true\" /> \n"
		"\n"
		"		<!-- Required texture compression support -->\n"
		"		<supports-gl-texture android:name=\"GL_IMG_texture_compression_pvrtc\" />\n"
		"		<supports-gl-texture android:name=\"GL_EXT_texture_compression_s3tc\" />\n"
		"\n"
		"		<!-- Required permissions -->\n")
	foreach(permission ${ANDROID_PERMISSIONS})
		file(APPEND ${apk_folder}/AndroidManifest.xml 
			"		<uses-permission android:name=\"android.permission.${permission}\" /> \n"
		)
	endforeach()
	file(APPEND ${apk_folder}/AndroidManifest.xml 
		"\n"
		"		<application android:label=\"@string/app_name\">\n"
		"			<!-- Our activity loads the generated bootstrapping class in order\n"
		"				to prelaod any third party shared libraries -->\n"
		"			<activity android:name=\"CryEngineActivity\"\n"
		"				android:label=\"@string/app_name\"\n"
		"				android:theme=\"@android:style/Theme.NoTitleBar.Fullscreen\"\n"
		"				android:screenOrientation=\"landscape\"\n"
		"				android:configChanges=\"orientation|keyboardHidden\">\n"
		"\n"
		"				<!-- Tell NativeActivity the name of our .so -->\n"
		"				<meta-data android:name=\"android.app.lib_name\" android:value=\"AndroidLauncher\" />\n"
		"				<intent-filter>\n"
		"					<action android:name=\"android.intent.action.MAIN\" />\n"
		"					<category android:name=\"android.intent.category.LAUNCHER\" />\n"
		"				</intent-filter>\n"
		"			</activity>\n"
		"		</application>\n"
		"\n"
		"	</manifest> \n"
		"	<!-- END_INCLUDE(manifest) -->\n"
	)

	#Generate resources
	file(MAKE_DIRECTORY ${apk_folder}/res/values)
	file(WRITE ${apk_folder}/res/values/string.xml
		"<?xml version=\"1.0\" encoding=\"utf-8\"?>\n"
		"<resources>\n"
		"	<string name=\"app_name\">${ANDROID_APP_NAME}</string>\n"
		"</resources>\n"
	)

	#Generate gdb.setup
	file(WRITE ${OUTPUT_DIRECTORY}/gdb.setup "set solib-search-path ${OUTPUT_DIRECTORY}/lib_debug/armeabi-v7a")
	
	#Generate ANT files
	file(WRITE ${apk_folder}/build.xml
		"<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n"
		"	<project name=\"${THIS_PROJECT}Launcher\" default=\"help\">\n"
		"\n"
		"		<property file=\"build.properties\" />\n"
		"\n"
		"		<!--REGION-BEGIN: The following properties allow Nsight Tegra to maintain build results per-configuration (debug, release, etc)-->\n"
		"		<target name=\"-pre-compile\">\n"
		"			<property name=\"nsight.tegra.project.all.jars.path\" value=\"\${toString:project.all.jars.path}\" />\n"
		"			<path id=\"project.all.jars.path\">\n"
		"				<path path=\"\${nsight.tegra.project.all.jars.path}\" />\n"
		"				<fileset dir=\"\${jar.libs.dir}\">\n"
		"					<include name=\"*.jar\" />\n"
		"				</fileset>\n"
		"			</path>\n"
		"			<echo>Ant Java version: \${ant.java.version}</echo>\n"
		"			<echo>Java Tools version: \${java.version}</echo>\n"
		"		</target>\n"
		"		<!--REGION-END-->\n"
		"\n"
		"		<!-- quick check on sdk.dir -->\n"
		"		<fail	message=\"sdk.dir is missing. Make sure to generate local.properties using 'android update project' or to inject it through the ANDROID_HOME environment variable.\"\n"
		"				unless=\"sdk.dir\" />\n"
		"\n"
		"		<!-- Import the actual build file.\n"
		"\n"
		"			To customize existing targets, there are two options:\n"
		"			1) Customize only one target:\n"
		"				- copy/paste the target into this file, *before* the <import> task.\n"
		"				#NAME?\n"
		"			2) Customize the whole content of build.xml\n"
		"				- copy/paste the content of the rules files (minus the top node) into this file, replacing the <import> task.\n"
		"				#NAME?\n"
		"\n"
		"			***********************\n"
		"			****** IMPORTANT ******\n"
		"			***********************\n"
		"			In all cases you must update the value of version-tag below to read 'custom' instead of an integer,\n"
		"			in order to avoid having your file be overridden by tools such as \"android update project\"\n"
		"		-->\n"
		"\n"
		"		<!-- version-tag: 1 -->\n"
		"		<import file=\"\\\${sdk.dir}/tools/ant/build.xml\" />\n"
		"	</project>\n"		
	)

	file(TO_CMAKE_PATH "$ENV{ANDROID_HOME}" ANDROID_SDK_DIR)

	file(WRITE ${apk_folder}/build.properties 
		"# This file is automatically generated by Android Tools.\n"
		"# Do not modify this file -- YOUR CHANGES WILL BE ERASED!\n"
		"\n"
		"target=android-${CMAKE_ANDROID_API}\n"
		"\n"
		"gen.absolute.dir=./gen\n"
		"out.dir=./bin\n"
		"jar.libs.dir=./libs\n"
		"native.libs.absolute.dir=./lib\n"
		"sdk.dir=${ANDROID_SDK_DIR}\n"
	)

endmacro()

macro(configure_android_launcher name)
	set(apk_folder "${CMAKE_BINARY_DIR}/${name}/apk_data")

	#Copy sources
	foreach(source_file ${SOURCES})
		if (${source_file} MATCHES ".*\\.\\java$")
			file(COPY ${source_file} DESTINATION ${apk_folder}/src)
		endif()
	endforeach()

	#Copy external libs
	file(COPY ${NDKROOT}/prebuilt/android-arm/gdbserver/gdbserver DESTINATION ${apk_folder}/lib/armeabi-v7a)
	file(COPY ${CMAKE_SOURCE_DIR}/Code/Tools/SDLExtension/lib/android-armeabi-v7a/libSDL2Ext.so DESTINATION ${apk_folder}/lib/armeabi-v7a)
	file(COPY ${SDK_DIR}/SDL2/lib/android-armeabi-v7a/libSDL2.so DESTINATION ${apk_folder}/lib/armeabi-v7a)

	#Make ANT run
	file(TO_NATIVE_PATH "${OUTPUT_DIRECTORY}" NATIVE_OUTDIR)
	file(TO_NATIVE_PATH "${apk_folder}" apk_folder_native)

	set(so_paths)
	if(NOT OPTION_STATIC_LINKING)
		foreach(mod ${SHARED_MODULES})
			set(so_paths "${so_paths} ${NATIVE_OUTDIR}\\lib${mod}.so")
		endforeach()
	endif()

	add_custom_command(TARGET ${THIS_PROJECT} POST_BUILD
		COMMAND copy ${NATIVE_OUTDIR}\\lib${name}.so ${so_paths} ${apk_folder_native}\\lib\\armeabi-v7a\\
		COMMAND call $ENV{ANT_HOME}/bin/ant clean
		COMMAND call $ENV{ANT_HOME}/bin/ant debug
		COMMAND copy ${apk_folder_native}\\bin\\${name}-debug.apk ${NATIVE_OUTDIR}\\${name}.apk WORKING_DIRECTORY ${apk_folder})	
endmacro()
