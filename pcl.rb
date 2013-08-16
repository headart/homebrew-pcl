require 'formula'

class Pcl < Formula
  homepage 'http://www.pointclouds.org'
  version '1.6.0'
  url 'https://github.com/PointCloudLibrary/pcl.git', :tag => 'pcl-1.6.0'

	devel do
    version '1.7.0'
		url 'https://github.com/PointCloudLibrary/pcl.git', :tag => 'pcl-1.7.0'
	end

  head 'https://github.com/PointCloudLibrary/pcl.git', :branch => 'master'

	fails_with :clang do
		build 421
		cause "Compilation fails with clang"
	end

  depends_on 'cmake'
  depends_on 'boost'
  depends_on 'eigen'
  depends_on 'flann'
  depends_on 'cminpack'
  depends_on 'vtk'
  depends_on 'qhull'
  depends_on 'libusb'

  depends_on 'doxygen' if build.include? '--doc'
  # pip install sphinx

  def options
  [
    [ '--apps'           , "Build apps"                      ],
    [ '--doc'            , "Build documentation"             ],
    [ '--nofeatures'     , "Disable features module"         ],
    [ '--nofilters'      , "Disable filters module"          ],
    [ '--noio'           , "Disable io module"               ],
    [ '--nokdtree'       , "Disable kdtree module"           ],
    [ '--nokeypoints'    , "Disable keypoints module"        ],
    [ '--nooctree'       , "Disable octree module"           ],
    [ '--noproctor'      , "Disable proctor module"          ],
    [ '--nopython'       , "Disable Python bindings"         ],
    [ '--norangeimage'   , "Disable range image module"      ],
    [ '--noregistration' , "Disable registration module"     ],
    [ '--nosac'          , "Disable sample consensus module" ],
    [ '--nosearch'       , "Disable search module"           ],
    [ '--nosegmentation' , "Disable segmentation module"     ],
    [ '--nosurface'      , "Disable surface module"          ],
    [ '--notools'        , "Disable tools module"            ],
    [ '--notracking'     , "Disable tracking module"         ],
    [ '--novis'          , "Disable visualisation module"    ],
    [ '--with-debug'     , "Enable gdb debugging"            ],
  ]
  end

  def install
    args = std_cmake_parameters.split

    args << "-DBUILD_documentation:BOOL=ON"  if build.include? '--doc'
		args << "-DBUILD_features:BOOL=OFF"      if build.include? '--nofeatures'
		args << "-DBUILD_filters:BOOL=OFF"       if build.include? '--nofilters'
		args << "-DBUILD_io:BOOL=OFF"            if build.include? '--noio'
		args << "-DBUILD_kdtree:BOOL=OFF"        if build.include? '--nokdtree'
		args << "-DBUILD_keypoints:BOOL=OFF"     if build.include? '--nokeypoints'
		args << "-DBUILD_octree:BOOL=OFF"        if build.include? '--nooctree'
		args << "-DBUILD_registration:BOOL=OFF"  if build.include? '--noregistration'
		args << "-DBUILD_search:BOOL=OFF"        if build.include? '--nosearch'
		args << "-DBUILD_segmentation:BOOL=OFF"  if build.include? '--nosegmentation'
		args << "-DBUILD_tools:BOOL=OFF"         if build.include? '--notools'
		args << "-DBUILD_tracking:BOOL=OFF"      if build.include? '--notracking'
		args << "-DBUILD_visualization:BOOL=OFF" if build.include? '--novis'
    # default on
		args << "-DBUILD_apps:BOOL=ON"
    args << "-DBUILD_2d:BOOL=ON"
    args << "-DBUILD_3d_rec_framework:BOOL=ON"
    args << "-DBUILD_CUDA:BOOL=ON"
    args << "-DBUILD_GPU:BOOL=ON"
    args << "-DBUILD_OPENNI:BOOL=ON"
    args << "-DBUILD_common:BOOL=ON"
    args << "-DBUILD_cuda_apps:BOOL=ON"
    args << "-DBUILD_cuda_io:BOOL=ON"
    args << "-DBUILD_examples:BOOL=ON"
    args << "-DBUILD_filters:BOOL=ON"
    args << "-DBUILD_geometry:BOOL=ON"
    args << "-DBUILD_global_tests:BOOL=ON"
    args << "-DBUILD_gpu_containers:BOOL=ON"
    args << "-DBUILD_gpu_features:BOOL=ON"
    args << "-DBUILD_gpu_kinfu:BOOL=ON"
    args << "-DBUILD_gpu_kinfu_large_scale:BOOL=ON"
    args << "-DBUILD_gpu_octree:BOOL=ON"
    args << "-DBUILD_gpu_segmentation:BOOL=ON"
    args << "-DBUILD_gpu_surface:BOOL=ON"
    args << "-DBUILD_gpu_utils:BOOL=ON"
    args << "-DBUILD_ml:BOOL=ON"
    args << "-DBUILD_outofcore:BOOL=ON"
    args << "-DBUILD_recognition:BOOL=ON"
    args << "-DBUILD_sample_consensus:BOOL=ON"
    args << "-DBUILD_stereo:BOOL=ON"
    # default off
    args << "-DBUILD_app_3d_rec_framework:BOOL=OFF"
    args << "-DBUILD_app_cloud_composer:BOOL=OFF"
    args << "-DBUILD_app_in_hand_scanner:BOOL=OFF"
    args << "-DBUILD_app_modeler:BOOL=OFF"
    args << "-DBUILD_app_optronic_viewer:BOOL=OFF"
    args << "-DBUILD_app_point_cloud_editor:BOOL=OFF"
    args << "-DBUILD_gpu_people:BOOL=OFF"
    args << "-DBUILD_gpu_tracking:BOOL=OFF"
    args << "-DBUILD_simulation:BOOL=OFF"

    ENV['CFLAGS']   ||= ''
    ENV['CXXFLAGS'] ||= ''

    if build.include? '--with-debug'
      ENV['CFLAGS']   += "-ggdb3 -O0"
      ENV['CXXFLAGS'] += "-ggdb3 -O0"
			args.delete '-DCMAKE_BUILD_TYPE=None'
			args << "-DCMAKE_BUILD_TYPE=Debug"
			args << "-DCMAKE_VERBOSE_MAKEFILE=true"
      debug_flags = "-ggdb3 -O0 -fno-inline -ggdb3"
			args << "-DCMAKE_C_FLAGS_DEBUG='#{debug_flags}'"
			args << "-DCMAKE_CXX_FLAGS_DEBUG='#{debug_flags}'"
    else
			args << "-DCMAKE_BUILD_TYPE=Release"
    end

		boost149_base    = Formula.factory('boost149').installed_prefix
		boost149_include = File.join(boost149_base, 'include')
		args << "-DBoost_INCLUDE_DIR=#{boost149_include}"

    # fix bad glew detection
		glew_base    = Formula.factory('glew').installed_prefix
		glew_include = File.join(glew_base, 'include')
    args << "-DGLEW_INCLUDE_DIR=#{glew_include}"

    # fix bad openni detection
		openni_base    = Formula.factory('openni').installed_prefix
		openni_include = File.join(openni_base, 'include')
    args << "-DOPENNI_INCLUDE_DIR=#{openni_include}/ni"

    ENV['CFLAGS']   += " -I#{openni_include}"
    ENV['CXXFLAGS'] += " -I#{openni_include}"

    sphinx_build = '/usr/local/share/python/sphinx-build'
    if File.exists? sphinx_build
      args << "-DSPHINX_EXECUTABLE=/usr/local/share/python/sphinx-build"
    end

    system "mkdir build"
    args << ".."
    Dir.chdir 'build' do
      system "cmake", *args
      system "make install"
    end
  end

  def test
    system "bash -c 'echo | plyheader'"
  end
end
