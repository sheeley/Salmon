require 'github_api'
require 'optparse'
require 'ostruct'

module Salmon
    class Application

        def self.run
            app = Application.new
            @options = app.parse_options(ARGV)
            source_github = app.config_github(@options.source)
            destination_github = app.config_github(@options.dest)

            repos = app.get_source_repos(source_github)

            abort("Retrieved no repositories") if repos.nil? or repos.empty?

            app.clone_repositories(destination_github, repos)
        end

        def parse_options(args)
            @options = Salmon::Config.parse_options(args)
        end

        def config_github(user_config)
            gh = Github.new do |config|
                user_config.marshal_dump.each do |key, value|
                    config.send("#{key}=", value) if config.respond_to? "#{key}="
                end
                config.auto_pagination = true
                config.per_page = 100
            end
            account = gh.users.get(user: user_config.name)
            user_config.type = account.type.downcase.to_sym
            gh
        end

        def get_source_repos(github)
            puts "Getting list of repos for #{@options.source.type}: #{@options.source.name}" if @options.verbose
            begin
                key = @options.source.type == :user ? :user : :org
                repos = github.repos.list("#{key}" => @options.source.name)
            rescue StandardError => e
                abort("Error getting list: #{e}")
            end
            repos
        end

        def clone_repositories(github, repos)
            temp_dir = Dir.mktmpdir(@options.temp_path)
            i = 1

            repos.each do |repo|
                repo.org = (@options.dest.type == :organization) ? @options.dest.name : nil
                repo.user = (@options.dest.type == :user) ? @options.dest.name : nil
                repo.created = false
                # TODO: error handling
                puts "Working on #{repo.name}:  #{i}/#{repos.length}"
                local_repo = "#{temp_dir}/#{repo.name}"
                eat_output = @options.verbose ? '' : ' > /dev/null'
                clone_cmd = "git clone #{repo.ssh_url} #{local_repo}#{eat_output}"

                system(clone_cmd)
                abort('Clone failed!') if $? != 0

                puts "Creating repo on #{github.site}" if @options.verbose
                begin
                    new_repo = github.repos.create(repo)
                    repo.created = true
                rescue Github::Error::UnprocessableEntity => ue
                    if ue.http_status_code == 422
                        puts "Repo already exists." if @options.verbose
                        new_repo = github.repos.get(@options.dest.name, repo.name)
                    else
                        puts(ue)
                    end
                rescue StandardError => se
                    puts(se)
                end

                if not new_repo.nil?
                    Dir.chdir(local_repo) do
                        system("git remote add clone #{new_repo['ssh_url']} #{eat_output}")
                        system("git push --all clone #{eat_output}")
                        system("git push --tags clone #{eat_output}") if @options.push_tags
                        puts "Pushed" if !@options.verbose
                    end
                else
                    puts "Repo wasn't created, can't push. :("
                end

                i += 1
            end
        end
    end
end
