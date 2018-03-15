class Intel < Compiler
  vendor :intel

  version do |language|
    `#{Settings.compilers[language]} -v 2>&1`.match(/^icc\s+.+\s+(\d+\.\d+\.\d+)/)[1]
  end
end