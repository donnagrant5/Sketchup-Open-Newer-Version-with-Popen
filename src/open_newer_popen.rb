require "tempfile"

module SW
  module OpenNewerVersion
    module OpenNewer
      # Major version of the running SketchUp.
      SU_VERSION = Sketchup.version.to_i

      # Newest major SketchUp version file format currently supported.
      # Update this along with recompiling binary with the new SDK.
      HIGHEST_SUPPORTED_SU_VERSION = 23

      # Get SketchUp version string of a saved file.
      #
      # @param path [String]
      #
      # @raise [IOError]
      #
      # @return [String]
      def self.version(path)
        v = File.binread(path, 64).tr("\x00", "")[/{([\d.]+)}/n, 1]

        v || raise(IOError, "Can't determine SU version for '#{path}'. Is file a model?")
      end

      # Ask user for path to open from.
      #
      # @return [String]
      def self.prompt_source_path
        UI.openpanel("Open", "", "SketchUp Models|*.skp||")
      end

      # Ask user for path to save converted model to.
      #
      # @param source [String]
      #
      # @return [String]
      def self.prompt_target_path(source)
        # Prefixing version with 20 as SketchUp 2014 is the oldest supported
        # version. If ever supporting versions 8 or older, only prefix for
        # [20]13 and above.
        title = "Save As SketchUp 20#{SU_VERSION} Compatible"
        directory = File.dirname(source)
        filename = "#{File.basename(source, '.skp')} (SU 20#{SU_VERSION}).skp"

        UI.savepanel(title, directory, filename)
      end

      # Convert an external model to the current SU version and open it.
      #
      # @param source [String]
      # @param target [String]
      #
      # @return [Void]
      def self.convert_and_open(source, target)
        Sketchup.status_text = "Converting model to supported format..."
        File.delete(target) if File.exist?(target)

        status = run_converter(source, target)
        if status[0] == 0
          Sketchup.open_file(target) # open converted file
        else 
          UI.messagebox(*status[1], MB_OK)
        end

        nil
      end

      # Popen the ConvertVerson exe
      #
      # @param source [String]
      # @param target [String]
      #
      # @return [Array[status [Int], erro_text Array[String]]
    def self.run_converter(source, target)
      begin
        env = {}
        #prog = File.join( PLUGIN_DIR, 'cpp', 'x64', 'release', 'sw_ConvertVersion.exe' )
        prog = File.join( PLUGIN_DIR, 'bin', 'sw_ConvertVersion.exe' )
        args = [ source, target, SU_VERSION.to_s ]
        cmd  = [env, prog, *args, :err=>[:child, :out] ]

        results = ""
        IO.popen(cmd, mode = 'a+') { |stream|
          # EOF occurs when the EXE closes the stream
          until stream.eof? do
            data = stream.readline
            results << data
          end
          
          # Gather child completion status 
          wait_thr = Process.detach(stream.pid)          
          process_status = wait_thr.value
          exit_status = process_status.exitstatus
          [exit_status, results]
        }
      rescue => exception
        puts exception.message
      end
    end
 
      # Ask for path to open, convert if needed and open.
      #
      # @return [Void]
      def self.open_newer_version
        source = prompt_source_path || return
        version = version(source).to_i
        if version <= SU_VERSION
          Sketchup.open_file(source)
          return
        end
        if version > HIGHEST_SUPPORTED_SU_VERSION
          msg =
            "This version of #{EXTENSION.name} does not support "\
            "SketchUp 20#{version} files."
          UI.messagebox(msg)
          return
        end
        target = prompt_target_path(source) || return
        convert_and_open(source, target)

        nil
      end
    end
  end
end
