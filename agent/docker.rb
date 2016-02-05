require 'docker'

module MCollective
  module Agent
    class Docker < RPC::Agent
      def startup_hook
        ::Docker.url = @config.pluginconf.fetch("docker.url", "unix:///var/run/docker.sock")
      end

      action "ps" do
        begin
          reply[:containers] = []
          ::Docker::Container.all(:all => request[:all]).each do |container|
            reply[:containers] << container.info
          end
        rescue Exception => e
          reply.fail("Failed to look up containers (#{e.message.chomp})")
        end
      end

      action "images" do
        begin
          reply[:images] = []
          ::Docker::Image.all(:all => request[:all]).each do |image|
            reply[:images] << image.info
          end
        rescue Exception => e
          reply.fail("Failed to look up images (#{e.message.chomp})")
        end
      end

      action "info" do
        begin
          case request[:type]
            when "container"
              obj = ::Docker::Container.get(request[:id])

            when "image"
              obj = ::Docker::Image.get(request[:id])
          end

          begin
            reply[:info] = obj.info
          rescue
            reply.fail("failed to retrieve information (#{e.message.chomp})")
          end
        rescue ::Docker::Error::NotFoundError
          reply.fail("not found")
        rescue Exception => e
          reply.fail("look up failed (#{e.message.chomp})")
        end
      end

      action "diff" do
        begin
          reply[:diff] = ::Docker::Container.get(request[:container_id]).changes
        rescue ::Docker::Error::NotFoundError
          reply.fail("not found")
        rescue Exception => e
          reply.fail("look up failed (#{e.chomp})")
        end
      end

      action "status" do
        begin
          container = ::Docker::Container.get(request[:container_id])
          container.info['State'].each do |k, v|
            reply[k.downcase.to_sym] = v
          end
        rescue ::Docker::Error::NotFoundError
          reply.fail("not found")
        rescue Exception => e
          reply.fail("look up failed (#{e.message.chomp})")
        end
      end

      action "start" do
        begin
          container = ::Docker::Container.get(request[:container_id])
          if container.info['State']['Status'] == 'running'
            reply.fail("already running")
          else
            begin
              container.start
            rescue Exception => e
              reply.fail("start failed (#{e.message.chomp})'")
            end
          end
        rescue ::Docker::Error::NotFoundError
          reply.fail("not found")
        rescue Exception => e
          reply.fail("look up failed (#{e.message.chomp})")
        end
      end

      action "stop" do
        begin
          container = ::Docker::Container.get(request[:container_id])
          if container.info['State']['Status'] != 'running'
            reply.fail("already stopped")
          else
            begin
              container.stop
            rescue Exception => e
              reply.fail("stop failed (#{e.message.chomp})")
            end
          end
        rescue ::Docker::Error::NotFoundError
          reply.fail("not found")
        rescue Exception => e
          reply.fail("look up failed (#{e.message.chomp})")
        end
      end

      action "restart" do
        begin
          container = ::Docker::Container.get(request[:container_id])
          if container.info['State']['Restarting']
            reply.fail("already restarting")
          else
            begin
              container.restart
            rescue Exception => e
              reply.fail("restart failed (#{e.message.chomp})")
            end
          end
        rescue ::Docker::Error::NotFoundError
          reply.fail("not found")
        rescue Exception => e
          reply.fail("look up failed (#{e.message.chomp})")
        end
      end

      action "kill" do
        begin
          container = ::Docker::Container.get(request[:container_id])
          if container.info['State']['Status'] != 'running'
          else
            begin
              container.kill(:signal => request[:signal])
            rescue Exception => e
              reply.fail("kill failed (#{e.message.chomp})")
            end
          end
        rescue ::Docker::Error::NotFoundError
          reply.fail("not found")
        rescue Exception => e
          reply.fail("look up failed (#{e.message.chomp})")
        end
      end

      action "pause" do
        begin
          container = ::Docker::Container.get(request[:container_id])
          if container.info['State']['Paused']
            reply.fail("already paused")
          else
            begin
              container.pause
            rescue Exception => e
              reply.fail("pause failed (#{e.message.chomp})")
            end
          end
        rescue ::Docker::Error::NotFoundError
          reply.fail("not found")
        rescue Exception => e
          reply.fail("look up failed (#{e.message.chomp})")
        end
      end

      action "unpause" do
        begin
          container = ::Docker::Container.get(request[:container_id])
          if ! container.info['State']['Paused']
            reply.fail("not paused")
          else
            begin
              container.unpause
            rescue Exception => e
              reply.fail("unpause failed (#{e.message.chomp})")
            end
          end
        rescue ::Docker::Error::NotFoundError
          reply.fail("not found")
        rescue Exception => e
          reply.fail("look up failed (#{e.message.chomp})")
        end
      end

      action "rm" do
        begin
          container = ::Docker::Container.get(request[:container_id])
          begin
            container.delete(:force => request[:force])
          rescue Exception => e
            reply.fail("remove failed (#{e.message.chomp})")
          end
        rescue ::Docker::Error::NotFoundError
          reply.fail("not found")
        rescue Exception => e
          reply.fail("look up failed (#{e.message.chomp})")
        end
      end

      action "logs" do
        begin
          container = ::Docker::Container.get(request[:container_id])
          begin
	    reply[:logs] = container.logs(stdout: true)
          rescue Exception => e
            reply.fail("logs fetch failed (#{e.message.chomp})")
          end
        rescue ::Docker::Error::NotFoundError
          reply.fail("not found")
        rescue Exception => e
          reply.fail("look up failed (#{e.message.chomp})")
        end
      end

      action "exec" do
        begin
          container = ::Docker::Container.get(request[:container_id])
          if container.info['State']['Status'] != 'running'
            reply.fail("not running")
          else
            begin
              reply[:output], reply[:error], reply[:exitcode] = container.exec(request[:command], wait: request[:wait])
            rescue Exception => e
              reply.fail("execute failed (#{e.message.chomp})")
            end
          end
        rescue ::Docker::Error::NotFoundError
          reply.fail("not found")
        rescue Exception => e
          reply.fail("look up failed (#{e.message.chomp})")
        end
      end

      action "rmi" do
        begin
          image = ::Docker::Image.get(request[:image_id])
          begin
            image.remove(:force => request[:force])
          rescue Exception => e
            reply.fail("remove failed (#{e.message.chomp})")
          end
        rescue ::Docker::Error::NotFoundError
          reply.fail("not found")
        rescue Exception => e
          reply.fail("look up failed (#{e.message.chomp})")
        end
      end

      action "top" do
        begin
          container = ::Docker::Container.get(request[:container_id])
          begin
	    reply[:processes] = container.top
          rescue Exception => e
            reply.fail("top failed (#{e.message.chomp})")
          end
        rescue ::Docker::Error::NotFoundError
          reply.fail("not found")
        rescue Exception => e
          reply.fail("look up failed (#{e.message.chomp})")
        end
      end

      action "pull" do
        begin
          if ::Docker::Image.exist?(request[:image_id])
            reply.fail("already pulled")
          else
            image = ::Docker::Image.create('fromImage' => request[:image_id])
	          reply[:image_id] = image.id
          end
        rescue Exception => e
          reply.fail("pull failed (#{e.message.chomp})")
        end
      end

      action "tag" do
        begin
          image = ::Docker::Image.get(request[:image_id])
          begin
            image.tag('repo' => request[:repo], 'tag' => request[:tag], :force => request[:force])
          rescue Exception => e
            reply.fail("tag failed (#{e.message.chomp})")
          end
        rescue ::Docker::Error::NotFoundError
          reply.fail("not found")
        rescue Exception => e
          reply.fail("look up failed (#{e.message.chomp})")
        end
      end
    end
  end
end
