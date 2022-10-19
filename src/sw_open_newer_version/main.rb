module SW
  module OpenNewerVersion
    if Sketchup.platform != :platform_win
      UI.messagebox("#{EXTENSION.name} is only supported on Windows.")
    elsif Sketchup.respond_to?(:is_64bit?) && !Sketchup.is_64bit?
      # Can't detect and handle 32 bitness in SU 2014 :( .
      UI.messagebox("#{EXTENSION.name} requires 64 bit Windows.")
    elsif Sketchup.version.to_i < 14
      UI.messagebox("#{EXTENSION.name} requires SketchUp 2014 or newer.")
    else
      Sketchup.require File.join(PLUGIN_DIR, "menu")
    end
  end
end
