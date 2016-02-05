metadata :name => "MCollective Docker Agent",
         :description => "MCollective Agent to orchestrate Docker",
         :author => "Matteo Cerutti <matteo.cerutti@hotmail.co.uk>",
         :license => "Apache 2.0",
         :version => "0.0.5",
         :url => "http://github.com/m4ce/mcollective-docker-agent",
         :timeout => 60

requires :mcollective => "2.2.1"

action "ps", :description => "List containers" do
  input :all,
    :description => "Show all containers, not only running ones",
    :optional    => true,
    :prompt      => "Show all",
    :type        => :boolean,
    :default     => false

  output :containers,
    :description  => "List of containers",
    :display_as   => "Containers"
end

action "images", :description => "List images" do
  input :all,
    :description => "Show all images (by default filter out the intermediate image layers)",
    :optional    => true,
    :prompt      => "Show all",
    :type        => :boolean,
    :default     => false

  output :images,
    :description => "List of images",
    :display_as  => "Images"
end

action "info", :description => "Inspect a container or image" do
  display :always

  input :type,
    :prompt      => "Type",
    :description => "Container or Image",
    :type        => :string,
    :validation  => '^(container|image)$',
    :optional    => false,
    :maxlength   => 9

  input :id,
    :prompt      => "ID",
    :description => "Container/Image ID",
    :type        => :string,
    :validation  => '^[a-z0-9_.\-\/:]+$',
    :optional    => false,
    :maxlength   => 256

  output :info,
    :description => "Container/image information",
    :display_as  => "Info"
end

action "diff", :description => "Inspect changes on a container's filesystem" do
  display :always

  input :container_id,
    :description => "ID",
    :prompt      => "Container ID",
    :type        => :string,
    :validation  => '^[a-zA-Z0-9\-_]+$',
    :optional    => false,
    :maxlength   => 30

  output :diff,
    :description => "List of changes",
    :display_as  => "Changes"
end

action "status", :description => "Show a container status" do
  display :always

  input :container_id,
    :description => "ID",
    :prompt      => "Container ID",
    :type        => :string,
    :validation  => '^[a-zA-Z0-9\-_]+$',
    :optional    => false,
    :maxlength   => 30

  output :status,
    :description => "Container status",
    :display_as  => "Status"

  output :running,
    :description => "Running status",
    :display_as  => "Running"

  output :paused,
    :description => "Paused status",
    :display_as  => "Paused"

  output :restarting,
    :description => "Restarting status",
    :display_as  => "Restarting"

  output :oomkilled,
    :description => "OOMKilled status",
    :display_as  => "OOMKilled"

  output :dead,
    :description => "Dead status",
    :display_as  => "Dead"

  output :pid,
    :description => "PID",
    :display_as  => "Pid"

  output :exitcode,
    :description => "Exit code",
    :display_as  => "ExitCode"

  output :error,
    :description => "Error",
    :display_as  => "Error"

  output :startedat,
    :description => "Start time",
    :display_as  => "StartedAt"

  output :finishedat,
    :description => "Finish time",
    :display_as  => "FinishedAt"
end

action "start", :description => "Start a container" do
  display :always

  input :container_id,
    :description => "ID",
    :prompt      => "Container ID",
    :type        => :string,
    :validation  => '^[a-zA-Z0-9\-_]+$',
    :optional    => false,
    :maxlength   => 30
end

action "stop", :description => "Stop a container by sending SIGTERM and then SIGKILL after a grace period" do
  display :always

  input :container_id,
    :description => "ID",
    :prompt      => "Container ID",
    :type        => :string,
    :validation  => '^[a-zA-Z0-9\-_]+$',
    :optional    => false,
    :maxlength   => 30
end

action "kill", :description => "Kill a running container using SIGKILL or a specified signal" do
  display :always

  input :container_id,
    :description => "ID",
    :prompt      => "Container ID",
    :type        => :string,
    :validation  => '^[a-zA-Z0-9\-_]+$',
    :optional    => false,
    :maxlength   => 30

  input :signal,
    :description => "Kill signal",
    :prompt      => "Signal",
    :type        => :string,
    :validation  => '^SIG[A-Z0-9]+$',
    :default     => "SIGKILL",
    :optional    => true,
    :maxlength   => 15
end

action "restart", :description => "Restart a running container" do
  display :always

  input :container_id,
    :description => "ID",
    :prompt      => "Container ID",
    :type        => :string,
    :validation  => '^[a-zA-Z0-9\-_]+$',
    :optional    => false,
    :maxlength   => 30
end

action "pause", :description => "Pause all processes within a container" do
  display :always

  input :container_id,
    :description => "ID",
    :prompt      => "Container ID",
    :type        => :string,
    :validation  => '^[a-zA-Z0-9\-_]+$',
    :optional    => false,
    :maxlength   => 30
end

action "unpause", :description => "Unpause all processes within a container" do
  display :always

  input :container_id,
    :description => "ID",
    :prompt      => "Container ID",
    :type        => :string,
    :validation  => '^[a-zA-Z0-9\-_]+$',
    :optional    => false,
    :maxlength   => 30
end

action "rm", :description => "Remove a container" do
  display :always

  input :container_id,
    :description => "ID",
    :prompt      => "Container ID",
    :type        => :string,
    :validation  => '^[a-zA-Z0-9\-_]+$',
    :optional    => false,
    :maxlength   => 30

  input :force,
    :description => "Force the removal of a running container",
    :prompt      => "Force removal",
    :type        => :boolean,
    :optional    => true,
    :default     => false
end

action "rmi", :description => "Remove an image" do
  display :always

  input :image_id,
    :description => "ID",
    :prompt      => "Image ID",
    :type        => :string,
    :validation  => '^[a-zA-Z0-9\-_]+$',
    :optional    => false,
    :maxlength   => 30

  input :force,
    :description => "Force the removal of the image",
    :prompt      => "Force removal",
    :type        => :boolean,
    :optional    => true,
    :default     => false
end

action "logs", :description => "Fetch the logs of a container" do
  display :always

  input :container_id,
    :description => "ID",
    :prompt      => "Container ID",
    :type        => :string,
    :validation  => '^[a-zA-Z0-9\-_]+$',
    :optional    => false,
    :maxlength   => 30

  output :logs,
    :description => "Container logs",
    :display_as  => "Logs"
end

action "exec", :description => "Execute a command in a running container" do
  display :always

  input :container_id,
    :description => "ID",
    :prompt      => "Container ID",
    :type        => :string,
    :validation  => '^[a-zA-Z0-9\-_]+$',
    :optional    => false,
    :maxlength   => 30

  input :wait,
    :description => "Wait",
    :prompt      => "Command timeout",
    :type        => :number,
    :default     => 60,
    :optional    => true

  output :output,
    :description => "Command standard output",
    :display_as  => "Output"

  output :error,
    :description => "Command standard error",
    :display_as  => "Error"

  output :exitcode,
    :description => "Command exit code",
    :display_as  => "ExitCode"
end

action "top", :description => "Display the running processes of a container" do
  display :always

  input :container_id,
    :description => "ID",
    :prompt      => "Container ID",
    :type        => :string,
    :validation  => '^[a-zA-Z0-9\-_]+$',
    :optional    => false,
    :maxlength   => 30

  output :processes,
    :description => "List of processes",
    :display_as  => "Processes"
end

action "pull", :description => "Pull an image or a repository from a registry" do
  display :always

  input :image_id,
    :description => "Image",
    :prompt      => "Image Name",
    :type        => :string,
    :validation  => '^[a-z0-9_.-\/:]+$',
    :optional    => false,
    :maxlength   => 255

  output :image_id,
    :description => "Image ID",
    :display_as  => "ID"
end

action "tag", :description => "Tag an image into a repository" do
  display :always

  input :image_id,
    :description => "Image",
    :prompt      => "Image ID/Name",
    :type        => :string,
    :validation  => '^[a-z0-9_.-\/:]+$',
    :optional    => false,
    :maxlength   => 255

  input :force,
    :description => "Force the alias",
    :prompt      => "Force the alias",
    :type        => :boolean,
    :optional    => true,
    :default     => false

  input :repo,
    :description => "Image Repository",
    :prompt      => "Repository",
    :type        => :string,
    :validation  => '^[a-z0-9_.-\/]+$',
    :optional    => false,
    :maxlength   => 255

  input :tag,
    :description => "Image Tag",
    :prompt      => "Tag",
    :type        => :string,
    :validation  => '^[a-z0-9_.-:]+$',
    :default     => "latest",
    :optional    => true,
    :maxlength   => 255
end
