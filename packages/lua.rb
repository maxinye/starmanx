class Lua < Package
  url 'https://www.lua.org/ftp/lua-5.3.4.tar.gz'
  sha256 'f681aa518233bc407e23acf0f5887c884f17436f000d453b2491a9f11a52400c'

  label :common
	label :skip_if_exist, include_file: 'lua.h'

	def install
		inreplace 'src/Makefile', {
			/^\s*CC\s*=.*$/ => "CC = #{CompilerSet.c.command}",
		}
		inreplace 'src/luaconf.h', {
			/#define LUA_ROOT.*/ => "#define LUA_ROOT \"#{prefix}\""
		}
		if OS.linux?
			platform = 'linux'
		elsif OS.mac?
			platform = 'macosx'
		else
			platform = 'generic'
		end
		run 'make', platform, "INSTALL_TOP=#{prefix}", "INSTALL_MAN=#{man}/man1"
		run 'make', 'install', "INSTALL_TOP=#{prefix}", "INSTALL_MAN=#{man}/man1"
    mkdir_p "#{lib}/pkgconfig"
    File.open("#{lib}/pkgconfig/lua.pc", 'w') do |file|
      file << <<-EOT
V= #{version.major_minor}
R= #{version}
prefix=#{prefix}
INSTALL_BIN= ${prefix}/bin
INSTALL_INC= ${prefix}/include
INSTALL_LIB= ${prefix}/lib
INSTALL_MAN= ${prefix}/share/man/man1
INSTALL_LMOD= ${prefix}/share/lua/${V}
INSTALL_CMOD= ${prefix}/lib/lua/${V}
exec_prefix=${prefix}
libdir=${exec_prefix}/lib
includedir=${prefix}/include

Name: Lua
Description: An Extensible Extension Language
Version: #{version}
Requires:
Libs: -L${libdir} -llua -lm
Cflags: -I${includedir}
      EOT
    end
	end
end
