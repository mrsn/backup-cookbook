actions :create, :delete
default_action :create

attribute :name, :kind_of => Symbol, :name_attribute => true, :required => true
attribute :description, :kind_of => String
attribute :definition, :kind_of => String, :required => true
attribute :cron_options, :kind_of => Hash
attribute :schedule, :kind_of => Hash
