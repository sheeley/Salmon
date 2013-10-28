require 'yaml'

module Salmon
    class Config
        def self.parse_options(args)
            options = OpenStruct.new

            path = File.expand_path('~/.salmon')
            abort("Please create a YAML server config file at ~/.salmon") if not File.readable?(path)
            githubs = YAML.load(File.read(path))

            options.temp_path = 'salmon'
            options.push_tags = true
            options.push_branches = ['*']
            options.verbose = true

            OptionParser.new do |opts|
                opts.banner = "Usage: salmon [options]"

                opts.separator ""
                opts.separator "Available sites:"
                opts.separator githubs.keys.join(", ")
                opts.separator ""

                opts.on("-s", "--source [SITE:ACCOUNT]", "Site name or source:destination string. Available: #{githubs.keys.join(', ')}") do |source|
                    source = source.split(":")
                    options.source = OpenStruct.new(githubs[source.first])
                    options.source.name = source.last
                end

                opts.on("-t", "--target [SITE:ACCOUNT]", "Organization or user name(s). Source only or source:destination.") do |source|
                    source = source.split(":")
                    options.dest = OpenStruct.new(githubs[source.first])
                    options.dest.name = source.last
                end

                #TODO: clone only might be nice

                opts.on("-p", "--tags", "Include tags when pushing") do |v|
                    options.push_tags = v
                end

                opts.on("-v", "--[no-]verbose", "Run verbosely") do |v|
                    options[:verbose] = v
                end

                opts.on_tail("--version", "Show version") do
                    puts Salmon::VERSION
                    exit
                end
            end.parse!(args)
            self.validate!(options)
            options
        end

        def self.validate!(options)
            {source: options.source, destination: options.dest}.each do |title, settings|
                abort("You must include #{title.to_s} settings") if settings.nil?
                abort("Please include name for both #{title.to_s} account") if settings.name.nil?
            end
        end
    end
end
