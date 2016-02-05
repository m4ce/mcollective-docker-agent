require 'docker'

module MCollective
  module Util
    class Docker
      def initialize
        config = Config.instance
        ::Docker.url = config.pluginconf.fetch("docker.url", "unix:///var/run/docker.sock")
      end

      def ps
        ::Docker::Container.all(:all => true)
      end

      def images
        ::Docker::Image.all(:all => true)
      end

      def info(opts)
        case opts[:type]
          when "container"
            ::Docker::Container.get(opts[:id]).info

          when "image"
            ::Docker::Image.get(opts[:id]).info
        end
      end
    end
  end
end
