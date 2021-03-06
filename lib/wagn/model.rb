Wagn.send :include, Wagn::Exceptions
Wagn::Set::Self::Settings

module Wagn::Model
  include Wagn::Pack

  def self.included(base)
    base.extend Wagn::Model::ModuleMethods
    base.superclass.extend Wagn::Model::ActsAsCardExtension
    base.send :include, Wagn::Model::AttributeTracking
    base.send :include, Wagn::Model::Collection
    base.send :include, Wagn::Model::Exceptions
    base.send :include, Wagn::Model::Fetch
    base.send :include, Wagn::Model::Templating
    base.send :include, Wagn::Model::TrackedAttributes
    base.send :include, Wagn::Model::Permissions
    base.send :include, Wagn::Model::References
    base.send :include, Wagn::Model::Settings
  end
end

