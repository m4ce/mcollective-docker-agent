module MCollective
  module Data
    class Docker_image_data < Base
      activate_when do
        require 'mcollective/util/docker/docker'
        true
      end

      query do |image|
        begin
          info = Util::Docker.new.info({:id => image, :type => "image"})
          result[:exists] = true
        rescue ::Docker::Error::NotFoundError
          result[:exists] = false
        rescue Exception => e
          Log.warn("Could not get image #{image} (#{e.message.chomp}")
        end
      end
    end
  end
end
