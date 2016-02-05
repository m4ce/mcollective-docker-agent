metadata :name => "MCollective Docker Container Data",
         :description => "",
         :author => "Matteo Cerutti <matteo.cerutti@hotmail.co.uk>",
         :license => "Apache 2.0",
         :version => "0.0.1",
         :url => "https://github.com/m4ce/mcollective-docker-agent",
         :timeout => 1

dataquery :description => "Container" do
  input :query,
        :prompt => "Container",
        :description => "Container ID or Name",
        :type => :string,
        :validation => :string,
        :maxlength => 255

  output :exists,
         :description => "Matches if there exists a container matching the query",
         :display_as => "Exists?"

  output :status,
         :description => "Matches if the container status",
         :display_as => "Status"

  output :running,
         :description => "Whether a container is running or not",
         :display_as => "Running?"

  output :restarting,
         :description => "Whether a container is restarting or not",
         :display_as => "Restarting?"

  output :paused,
         :description => "Whether a container is paused or not",
         :display_as => "Paused?"

  output :dead,
         :description => "Whether a container is dead or not",
         :display_as => "Dead?"

  output :oomkilled,
         :description => "OOMKilled",
         :display_as => "OOMKilled?"
end
