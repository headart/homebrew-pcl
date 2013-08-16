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

    if ARGV.include? '--noapps'
      args << "-DBUILD_apps:BOOL=OFF"
    end
    if ARGV.include? '--doc'
      args << "-DBUILD_documentation:BOOL=ON"
    else
      args << "-DBUILD_documentation:BOOL=OFF"
    end
    if ARGV.include? '--nofeatures'
      args << "-DBUILD_features:BOOL=OFF"
    end
    if ARGV.include? '--nofilters'
      args << "-DBUILD_filters:BOOL=OFF"
    end
    if ARGV.include? '--noio'
      args << "-DBUILD_io:BOOL=OFF"
    end
    if ARGV.include? '--nokdtree'
      args << "-DBUILD_kdtree:BOOL=OFF"
    end
    if ARGV.include? '--nokeypoints'
      args << "-DBUILD_keypoints:BOOL=OFF"
    end
    if ARGV.include? '--nooctree'
      args << "-DBUILD_octree:BOOL=OFF"
    end
    if ARGV.include? '--noproctor'
      args << "-DBUILD_proctor:BOOL=OFF"
    end
    if ARGV.include? '--nopython'
      args << "-DBUILD_python:BOOL=OFF"
    end
    if ARGV.include? '--norangeimage'
      args << "-DBUILD_rangeimage:BOOL=OFF"
    end
    if ARGV.include? '--noregistration'
      args << "-DBUILD_registration:BOOL=OFF"
    end
    if ARGV.include? '--nosac'
      args << "-DBUILD_sac:BOOL=OFF"
    end
    if ARGV.include? '--nosearch'
      args << "-DBUILD_search:BOOL=OFF"
    end
    if ARGV.include? '--nosegmentation'
      args << "-DBUILD_segmentation:BOOL=OFF"
    end
    if ARGV.include? '--nosurface'
      args << "-DBUILD_surface:BOOL=OFF"
    end
    if ARGV.include? '--notools'
      args << "-DBUILD_tools:BOOL=OFF"
    end
    if ARGV.include? '--notracking'
      args << "-DBUILD_tracking:BOOL=OFF"
    end
    if ARGV.include? '--novis'
      args << "-DBUILD_visualization:BOOL=OFF"
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

