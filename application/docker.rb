module MCollective
  class Application::Docker < Application
    description "Run docker commands"
 
    usage "mco docker [options] [command] [extra args]"

    option :all,
           :arguments   => ['-a', '--all'],
           :description => 'Show all images/containers',
           :type        => :bool,
           :default     => false

    option :wait,
           :arguments   => ['-w <SECONDS>', '--wait <SECONDS>'],
           :description => 'Wait for the command to finish executing, timing out after that number of seconds',
           :type        => Integer,
           :default     => 60

    option :signal,
           :arguments   => ['-s <SIGNAL>', '--signal <SIGNAL>'],
           :description => 'Kill the Container specifying the kill signal',
           :type        => String,
           :default     => "SIGKILL"

    option :type,
           :arguments   => ['-t <TYPE>', '--type <TYPE>'],
           :description => 'Container or image type',
           :type        => String

    option :force,
           :arguments   => ['-f', '--force'],
           :description => 'Force action',
           :type        => :bool,
           :default     => false

    def post_option_parser(configuration)
      if ARGV.size < 1
        raise "Please specify an action"
      end

      valid_actions = ["ps", "images", "inspect", "diff", "status", "start", "stop", "restart", "pause", "unpause", "kill", "rm", "rmi", "logs", "exec", "top", "pull", "tag"]
      action = ARGV.shift

      unless valid_actions.include?(action)
        raise "Action has to be one of " + valid_actions.join(', ')
      end

      case action
        when "diff", "status", "start", "stop", "restart", "pause", "unpause", "kill", "rm", "exec", "logs", "top"
          raise "Must provide a Container ID/Name to #{action}" unless ARGV.length > 0
          configuration[:container_id] = ARGV.shift

        when "inspect"
          raise "Must provide a Container or Image ID/Name to #{action}" unless ARGV.length > 0
          configuration[:id] = ARGV.shift

        when "pull"
          raise "Must provide an Image Name to #{action}" unless ARGV.length > 0
          configuration[:image_id] = ARGV.shift

        when "tag"
          raise "Must provide an Image ID/Name to #{action}" unless ARGV.length > 0
          configuration[:image_id] = ARGV.shift
          raise "Must provide an Image alias to #{action}" unless ARGV.length > 0
          configuration[:alias] = ARGV.shift

        when "exec"
          raise "Must provide a command to #{action}" unless ARGV.length > 0

        when "rmi"
          raise "Must provide an Image ID/Name to #{action}" unless ARGV.length > 0
          configuration[:image_id] = ARGV.shift
      end

      configuration[:action] = action
      configuration[:arguments] = ARGV
    end
 
    def main
      send("#{configuration[:action]}_action")
      printrpcstats :summarize => true
    end

    private

    def human_duration(ts)
      diff = Time.now.to_i - ts
      if diff < 1
        "Less than a second ago"
      elsif diff < 60 # < 1m
        "#{diff} seconds ago"
      elsif diff >= 60 and diff < 120 # >= 1m < 2m
        "About a minute"
      elsif diff < 3600 # < 1h
        "#{diff / 60} minutes ago"
      elsif diff < 7200 # < 2h
        "About an hour"
      elsif diff < (86400 * 2) # < 2d
        "#{diff / 3600} hours ago"
      elsif diff < (86400 * 7 * 2) # < 2w
        "#{diff / 86400} days ago"
      elsif diff < (86400 * 30 * 3) # < 3m
        "#{diff / (86400 * 7)} weeks ago"
      elsif diff < (86400 * 365 * 2) # < 2y
        "#{diff / (86400 * 30)} months ago"
      else
        "#{diff / (86400 * 365)} years ago"
      end
    end

    def ps_action
      docker = rpcclient("docker")

      responses = docker.ps({:all => configuration[:all]})
      responses.sort_by! { |r| r[:sender] }

      count = 0
      responses.each do |response|
        puts if count > 0
        puts "#{response[:sender]}:"
        puts
        if response[:statuscode] == 0
          puts("  %-15s %-30s %-25s %-18s %-25s %s" % ["ID", "IMAGE", "COMMAND", "CREATED", "STATUS", "PORTS"])
          response[:data][:containers].each do |container|
            puts("  %-15s %-30s %-25s %-15s %-25s %s" % [container['id'][0..11], container['Image'][0..30], '"' + container['Command'][0..20] + '"', human_duration(container['Created']), container['Status'], container['Ports'].map { |i| "#{i['IP']}:#{i['PrivatePort']}->#{i['PublicPort']}/#{i['Type']}" }.join(', ')])
          end
        else
          puts("  #{response[:statusmsg]}")
        end
        count += 1
      end
    end

    def images_action
      docker = rpcclient("docker")

      responses = docker.images({:all => configuration[:all]})
      responses.sort_by! { |r| r[:sender] }

      count = 0
      responses.each do |response|
        puts if count > 0
        puts "#{response[:sender]}:"
        puts
        if response[:statuscode] == 0
          puts("  %-45s %-20s %-20s %-20s %s" % ["REPOSITORY", "TAG", "IMAGE ID", "CREATED", "VIRTUAL SIZE"])
          response[:data][:images].each do |image|
            puts("  %-45s %-20s %-20s %-20s %s" % [image['RepoTags'].first.split(':')[0], image['RepoTags'].first.split(':')[1], image['id'][0..12], human_duration(image['Created']), image['VirtualSize']])
          end
        else
          puts("  #{response[:statusmsg]}")
        end
        count += 1
      end
    end

    def inspect_action
      docker = rpcclient("docker")

      responses = docker.info({:id => configuration[:id], :type => configuration[:type]})
      responses.sort_by! { |r| r[:sender] }

      count = 0
      responses.each do |response|
        puts if count > 0
        puts("#{response[:sender]}:")
        puts
        if response[:statuscode] == 0
          JSON.pretty_generate(response[:data][:info]).each_line do |line|
            puts("  #{line}")
          end
        else
          puts("  #{response[:statusmsg]}")
        end
        count += 1
      end
    end

    def diff_action
      docker = rpcclient("docker")

      responses = docker.diff({:container_id => configuration[:container_id]})
      responses.sort_by! { |r| r[:sender] }

      count = 0
      responses.each do |response|
        puts if count > 0
        puts("#{response[:sender]}:")
        puts
        if response[:statuscode] == 0
          response[:data][:diff].each do |diff|
            puts("  %s %s" % [diff['Kind'] > 0 ? 'A' : 'C', diff['Path']])
          end
        else
          puts("  #{response[:statusmsg]}")
        end
        count += 1
      end
    end

    def status_action
      docker = rpcclient("docker")

      responses = docker.status({:container_id => configuration[:container_id]})
      responses.sort_by! { |r| r[:sender] }

      count = 0
      responses.each do |response|
        puts if count > 0
        puts("#{response[:sender]}:")
        puts
        if response[:statuscode] == 0
          response[:data].each do |k, v|
            puts "  #{k.to_s.capitalize}: #{v}"
          end
        else
          puts("  #{response[:statusmsg]}")
        end
        count += 1
      end
    end

    def start_action
      docker = rpcclient("docker")

      responses = docker.start({:container_id => configuration[:container_id]})
      responses.sort_by! { |r| r[:sender] }

      count = 0
      responses.each do |response|
        puts if count > 0
        puts("#{response[:sender]}:")
        puts
        if response[:statuscode] == 0
          puts("  Status: started")
        else
          puts("  Status: #{response[:statusmsg]}")
        end
        count += 1
      end
    end

    def stop_action
      docker = rpcclient("docker")

      responses = docker.stop({:container_id => configuration[:container_id]})
      responses.sort_by! { |r| r[:sender] }

      count = 0
      responses.each do |response|
        puts if count > 0
        puts("#{response[:sender]}:")
        puts
        if response[:statuscode] == 0
          puts("  Status: stopped")
        else
          puts("  Status: #{response[:statusmsg]}")
        end
        count += 1
      end
    end

    def restart_action
      docker = rpcclient("docker")

      responses = docker.restart({:container_id => configuration[:container_id]})
      responses.sort_by! { |r| r[:sender] }

      count = 0
      responses.each do |response|
        puts if count > 0
        puts("#{response[:sender]}:")
        puts
        if response[:statuscode] == 0
          puts("  Status: restarted")
        else
          puts("  Status: #{response[:statusmsg]}")
        end
        count += 1
      end
    end

    def kill_action
      docker = rpcclient("docker")

      responses = docker.kill({:container_id => configuration[:container_id], :signal => configuration[:signal]})
      responses.sort_by! { |r| r[:sender] }

      count = 0
      responses.each do |response|
        puts if count > 0
        puts("#{response[:sender]}:")
        puts
        if response[:statuscode] == 0
          puts("  Status: killed")
        else
          puts("  Status: #{response[:statusmsg]}")
        end
        count += 1
      end
    end

    def pause_action
      docker = rpcclient("docker")

      responses = docker.pause({:container_id => configuration[:container_id]})
      responses.sort_by! { |r| r[:sender] }

      count = 0
      responses.each do |response|
        puts if count > 0
        puts("#{response[:sender]}:")
        puts
        if response[:statuscode] == 0
          puts("  Status: paused")
        else
          puts("  Status: #{response[:statusmsg]}")
        end
        count += 1
      end
    end

    def unpause_action
      docker = rpcclient("docker")

      responses = docker.unpause({:container_id => configuration[:container_id]})
      responses.sort_by! { |r| r[:sender] }

      count = 0
      responses.each do |response|
        puts if count > 0
        puts("#{response[:sender]}:")
        puts
        if response[:statuscode] == 0
          puts("  Status: unpaused")
        else
          puts("  Status: #{response[:statusmsg]}")
        end
        count += 1
      end
    end

    def rm_action
      docker = rpcclient("docker")

      responses = docker.rm({:container_id => configuration[:container_id], :force => configuration[:force]})
      responses.sort_by! { |r| r[:sender] }

      count = 0
      responses.each do |response|
        puts if count > 0
        puts("#{response[:sender]}:")
        puts
        if response[:statuscode] == 0
          puts("  Status: removed")
        else
          puts("  Status: #{response[:statusmsg]}")
        end
        count += 1
      end
    end

    def rmi_action
      docker = rpcclient("docker")

      responses = docker.rmi({:image_id => configuration[:image_id], :force => configuration[:force]})
      responses.sort_by! { |r| r[:sender] }

      count = 0
      responses.each do |response|
        puts if count > 0
        puts("#{response[:sender]}:")
        puts
        if response[:statuscode] == 0
          puts("  Status: removed")
        else
          puts("  Status: #{response[:statusmsg]}")
        end
        count += 1
      end
    end

    def exec_action
      docker = rpcclient("docker")

      responses = docker.exec({:container_id => configuration[:container_id], :command => configuration[:arguments], :wait => configuration[:wait]})
      responses.sort_by! { |r| r[:sender] }

      count = 0
      responses.each do |response|
        puts if count > 0
        puts("#{response[:sender]}:")
        puts
        if response[:statuscode] == 0
          puts("  Status: executed")
          puts("  Standard output:")
          puts
          response[:data][:output].each do |line|
            puts "    #{line.chomp}"
          end
          if response[:data][:error].length > 0
            puts("  Standard error:")
            puts
            response[:data][:error].each do |line|
              puts("    #{line.chomp}")
            end
          end
          puts
          puts("  Exit Code: #{response[:data][:exitcode]}")
        else
          puts("  Status: #{response[:statusmsg]}")
        end
        count += 1
      end
    end

    def logs_action
      docker = rpcclient("docker")

      responses = docker.logs({:container_id => configuration[:container_id]})
      responses.sort_by! { |r| r[:sender] }

      count = 0
      responses.each do |response|
        puts if count > 0
        puts("#{response[:sender]}:")
        puts
        if response[:statuscode] == 0
          puts("  Container logs:")
          puts
          response[:data][:logs].split("\n").each do |log|
            puts("    #{log}")
          end
        else
          puts("  Status: #{response[:statusmsg]}")
        end
        count += 1
      end
    end

    def top_action
      docker = rpcclient("docker")

      responses = docker.top({:container_id => configuration[:container_id]})
      responses.sort_by! { |r| r[:sender] }

      count = 0
      responses.each do |response|
        puts if count > 0
        puts("#{response[:sender]}:")
        puts
        if response[:statuscode] == 0
          puts("  %-10s %-10s %-10s %-5s %-10s %-10s %-10s %s" % ["UID", "PID", "PPID", "C", "STIME", "TTY", "TIME", "CMD"])
          response[:data][:processes].each do |process|
            puts("  %-10s %-10s %-10s %-5s %-10s %-10s %-10s %s" % [process["UID"], process["PID"], process["PPID"], process["C"], process["STIME"], process["TTY"], process["TIME"], process["CMD"]])
          end
        else
          puts("  Status: #{response[:statusmsg]}")
        end
        count += 1
      end
    end

    def pull_action
      docker = rpcclient("docker")

      responses = docker.pull({:image_id => configuration[:image_id]})
      responses.sort_by! { |r| r[:sender] }

      count = 0
      responses.each do |response|
        puts if count > 0
        puts("#{response[:sender]}:")
        puts
        if response[:statuscode] == 0
          puts("  Status: fetched (ID: #{response[:data][:image_id][0..11]})")
        else
          puts("  Status: #{response[:statusmsg]}")
        end
        count += 1
      end
    end

    def tag_action
      docker = rpcclient("docker")

      repo, tag = configuration[:alias].split('/')
      opts = {:image_id => configuration[:image_id], :repo => repo, :force => configuration[:force]}
      opts[:tag] = tag if tag

      responses = docker.tag(opts)
      responses.sort_by! { |r| r[:sender] }

      count = 0
      responses.each do |response|
        puts if count > 0
        puts("#{response[:sender]}:")
        puts
        if response[:statuscode] == 0
          puts("  Status: tag created")
        else
          puts("  Status: #{response[:statusmsg]}")
        end
        count += 1
      end
    end
  end
end
