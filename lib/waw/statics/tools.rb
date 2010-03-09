module Waw
  module Statics
    module Tools
      
      # Encodes an image in base64
      def image2base64(imgfile)
        require 'base64'
        basename, ext, base64 = File.basename(imgfile), File.extname(imgfile), nil
        File.open(imgfile, 'r') {|io| base64 = Base64.encode64(io.read) }
        "data:image/#{ext[1..-1]};base64," << base64.gsub("\n","")
      end
      module_function :image2base64

      # Converts all url(...) references to images by their encoding in base64 in
      # a CSS file.
      def css_images2base64
        cssfile = File.join($public, 'css', 'style.css')
        File.read(cssfile).gsub(/url\(..\/(.*)\)/){|url| 
          imgfile = $1 if (url =~ /url\(..\/(.*)\)/)
          imgfile = File.join($public, imgfile)
          "url(#{image2base64(imgfile)})"
        }
      end
      module_function css_images2base64

    end # module Tools
  end # module Statics
end # module Waw