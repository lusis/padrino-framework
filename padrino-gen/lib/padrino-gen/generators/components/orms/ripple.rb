RIPPLE = (<<-RIPPLE) unless defined?(RIPPLE)
case Padrino.env
  when :development then RIPPLE_NAME = '!NAME!_development'
  when :production  then RIPPLE_NAME = '!NAME!_production'
  when :test        then RIPPLE_NAME = '!NAME!_test'
end
RIPPLE = Riak::Client.new()
RIPPLE

def setup_orm
  require_dependencies 'curb'
  require_dependencies 'yajl-ruby'
  require_dependencies 'activesupport', :version => ">= 3.0.0.rc2"
  require_dependencies 'activemodel', :version => ">= 3.0.0.rc2"
  require_dependencies 'riak-client', :version => ">= 0.8.0beta", :require => 'riak'
  require_dependencies 'ripple', :version => ">= 0.8.0beta"
  create_file("config/database.rb", RIPPLE.gsub(/!NAME!/, @app_name.underscore))
  empty_directory('app/models')
end

RIPPLE_MODEL = (<<-MODEL) unless defined?(RIPPLE_MODEL)
class !NAME!
  include Ripple::Document
  self.bucket_name = "!BUCKET_NAME!"

  !FIELDS!
  timestamps!
end
MODEL

# options => { :fields => ["title:string", "body:string"], :app => 'app' }
def create_model_file(name, options={})
    model_path = destination_root(options[:app], 'models', "#{name.to_s.underscore}.rb")
    field_tuples = options[:fields].collect { |value| value.split(":") }
    column_declarations = field_tuples.collect { |field, kind| "property :#{field}, #{kind.camelize}" }.join("\n  ")
    bucket_name = "#{name.pluralize.to_s.underscore}_#{options[:app].to_s.underscore.gsub("/","")}_#{PADRINO_ENV}"
    model_contents = RIPPLE_MODEL.gsub(/!NAME!/, name.to_s.camelize)
    model_contents.gsub!(/!FIELDS!/, column_declarations)
    model_contents.gsub!(/!MODEL_NAME!/, name.to_s.underscore)
    model_contents.gsub!(/!BUCKET_NAME!/, bucket_name)
    create_file(model_path, model_contents)
end

def create_model_migration(filename, name, fields)
  # NO MIGRATION NEEDED
end

def create_migration_file(migration_name, name, columns)
  # NO MIGRATION NEEDED
end
