top = File.expand_path(File.join(File.dirname(__FILE__), '..', '..'))
$LOAD_PATH.unshift(top, 'lib')
require 'fileutils'
require 'waw'

at_exit {
  temp = File.join(top, 'temp')
  FileUtils.mkdir temp unless File.exists?(temp)
  FileUtils.cd temp do |trg_dir|
    Dir[File.join(top, 'layouts', '*')].each do |layout_folder|
      layout = File.basename(layout_folder)
      puts "Testing layout #{layout} with top being #{top}"
  
      FileUtils.rm_rf layout
      `ruby -I#{File.join(top, 'lib')} #{File.join(top, 'bin', 'waw')} create --force --layout #{layout} #{layout}`
      
      # Kernel.load(File.join(layout, 'test', 'unit', 'test_all.rb'))
      # Kernel.load(File.join(layout, 'test', 'wawspec', 'test_all.rb'))
      # Waw.unload
      FileUtils.cd layout do |dir|
        puts `ruby -I#{File.join(top, 'lib')} test/unit/test_all.rb`
        puts `ruby -I#{File.join(top, 'lib')} test/wawspec/test_all.rb`
      end
    end
  end
  FileUtils.rm_rf temp
}