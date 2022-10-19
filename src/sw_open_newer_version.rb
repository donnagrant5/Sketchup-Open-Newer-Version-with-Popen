#-------------------------------------------------------------------------------
#
#    Author: Skip Williams
#     after the code from 
#    Julia Christina Eneroth
# Copyright: Copyright (c) 2021
#   License: MIT
#
#-------------------------------------------------------------------------------

require "extensions.rb"

module SW
module OpenNewerVersion

  path = __FILE__
  path.force_encoding("UTF-8") if path.respond_to?(:force_encoding)

  PLUGIN_ID = File.basename(path, ".*")
  PLUGIN_DIR = File.join(File.dirname(path), PLUGIN_ID)

  EXTENSION = SketchupExtension.new(
    "SW Open Newer Version",
    File.join(PLUGIN_DIR, "main")
  )
  EXTENSION.creator     = "S. Williams"
  EXTENSION.description =
    "Convert and open models made in newer versions of SketchUp."
  EXTENSION.version     = "1.0.1"
  EXTENSION.copyright   = "2022, #{EXTENSION.creator}"
  Sketchup.register_extension(EXTENSION, true)

end
end
