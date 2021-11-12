#!/usr/bin/env ruby

require 'optparse'

params = {}
OptionParser.new do |opts|
  opts.banner = './genere_plug-in_gimp.rb -n my_plugin -d "this is a description" -e "Use this plugin to ..." -l MIT -y 2021 -a rivsc -m "My great plugin" -x CURRENT_IMAGE'

  opts.on('-n NAME','--name NAME', String, "Just ASCII downcase without space")
  opts.on('-d DESCRIPTION', '--description DESCRIPTION', String, '"Description (blurb)"')
  opts.on('-e HELP', '--help HELP', String, "Help gimp plug-in")
  opts.on('-l LICENSE', '--license LICENSE', String, "eg : MIT")
  opts.on('-y DATE', '--year YYYY', String, "2021")
  opts.on('-a AUTHOR', '--author AUTHOR', String, "rivsc")
  opts.on('-m MENU_NAME', '--menu MENU_NAME', String, '"My great plugin"')
  opts.on('-x CURRENT_IMAGE', '--on_current_image CURRENT_IMAGE', String, 'Use CURRENT_IMAGE or blank string ""')
  opts.on('-v', '--verbose')
end.parse!(into: params)

p params

image_type = "RGB*, GRAY*"
parameters = <<-EOS
  (PF_FILENAME, "infile", "Input file", "." ),
  (PF_FILENAME, "outfile", "Output file", "." ),  
EOS
python_parameters = "infile,outfile"

if params[:x] == "CURRENT_IMAGE"
  image_type = "" # utilisera l'image courrante
  parameters = ""
  python_parameters = ""
end

python_src = <<-EOS
#!/usr/bin/env python

import gimpcolor
import math
from gimpfu import *

def #{params[:name]}(#{python_parameters}):

  # A white color
  #white = gimpcolor.RGB(255,255,255)

  # Load xcf or jpg
  #img = pdb.gimp_file_load(infile, infile)
  
  # Get active layer
  #drawable = pdb.gimp_image_get_active_layer(img)
   
  # Save XCF
  #pdb.gimp_xcf_save(0, img, None, outfile, outfile)

  # Save PNG
  #pdb.file_png_save(img, drawable2, outfile, outfile, 0,9,0,0,0,1,1)

# name, blurb, help, author, copyright, date, menu_path, image_types, type, params, ret_vals
register(
	"#{params[:name]}",
	"#{params[:description]}",
	"#{params[:help]}",
	"#{params[:author]}",
	"#{params[:license]}",
	"#{params[:year]}",
	"#{params[:menu]}",
	"#{image_type}",
	[
          #{parameters}
	],
	[],
	#{params[:name]},
    menu="<Image>/Tools")

main()
EOS

outfile = "#{params[:name]}.py"

File.open(outfile,"w+") do |f|
  f.write(python_src)
end

# Needed by gimp
`chmod +x #{outfile}`