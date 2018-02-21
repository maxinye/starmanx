class Settings
  extend Utils

  def self.cache_root
    '/tmp/starman'
  end

  def self.rc_root
    @@rc_root
  end

  def self.install_root
    @@settings['install_root']
  end

  def self.link_root
    @@settings['link_root']
  end

  def self.conf_file
    "#{rc_root}/conf.yml"
  end

  def self.compiler_set
    @@settings['defaults']['compiler_set']
  end

  def self.compilers
    @@settings['compiler_sets'][compiler_set]
  end

  def self.c_compiler
    compilers['c']
  end

  def self.cxx_compiler
    compilers['cxx']
  end

  def self.fortran_compiler
    compilers['fortran']
  end

  def self.init
    # rc_root has priority order: --rc-root > /var/starman > ~/.starman
    @@rc_root = CommandParser.args[:rc_root] || File.directory?('/var/starman') ? '/var/starman' : "#{ENV['HOME']}/.starman"
    if File.file? conf_file
      @@settings = YAML.load(open(conf_file).read)
      CLI.error "#{CLI.red 'install_root'} is not set in #{CLI.blue conf_file}!" if not install_root or install_root == '<change_me>'
      @@settings['link_root'] = "#{Settings.install_root}/#{Settings.compiler_set}"
      ENV['CC'] = c_compiler
      ENV['CXX'] = cxx_compiler
      ENV['FC'] = fortran_compiler
      ENV['F77'] = fortran_compiler
      ENV[OS.ld_library_path] = "#{link_root}/lib:#{link_root}/lib64:#{ENV[OS.ld_library_path]}"
      if CommandParser.args[:verbose]
        CLI.notice "Use #{CLI.blue compiler_set} compilers."
        CLI.notice "CC = #{CLI.blue c_compiler}"
        CLI.notice "CXX = #{CLI.blue cxx_compiler}"
        CLI.notice "FC = #{CLI.blue fortran_compiler}"
      end
    else
      begin
        CLI.notice "Create runtime configuration directory #{CLI.blue rc_root}."
        FileUtils.mkdir_p rc_root
        write_file conf_file, <<-EOS
---
install_root: <change_me>
defaults:
  compiler_set: <change_me>
compiler_sets:
  <change_me>:
    c: <change_me>
    cxx: <change_me>
    fortran: <change_me>
EOS
        CLI.notice "Please edit #{CLI.blue conf_file} to suit your environment and come back."
        exit
      rescue Errno::EACCES => e
        CLI.error "Failed to create runtime configuration directory at #{CLI.red rc_root}!\n#{e}"
      end
    end
  end
end
