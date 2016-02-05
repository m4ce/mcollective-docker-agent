module MCollective
  module Data
    class Docker_container_data < Base
      activate_when do
        require 'mcollective/util/docker/docker'
        true
      end

      query do |container|
        begin
          info = Util::Docker.new.info({:id => container, :type => "container"})
          info['State'].each do |k, v|
            result[k.downcase.to_sym] = v
          end
          result[:exists] = true
        rescue ::Docker::Error::NotFoundError
          result[:exists] = false
        rescue => e
          Log.warn("Could not get status for container #{container}: #{e.to_s}")
        end
      end
    end
  end
end
