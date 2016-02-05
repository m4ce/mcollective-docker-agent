metadata :name => "MCollective Docker Image Data",
         :description => "",
         :author => "Matteo Cerutti <matteo.cerutti@hotmail.co.uk>",
         :license => "Apache 2.0",
         :version => "0.0.1",
         :url => "https://github.com/m4ce/mcollective-docker-agent",
         :timeout => 1

dataquery :description => "Image" do
  input :query,
        :prompt => "Image",
        :description => "Image ID or Name",
        :type => :string,
        :validation => :string,
        :maxlength => 255

  output :exists,
         :description => "Matches if there exists an image matching the query",
         :display_as => "Exists?"
end
