class Role < ActiveRecord::Base
  acts_as_card_extension
  has_and_belongs_to_many :users
  cattr_accessor :cache
  
  class << self
    def find_configurables
      @roles = Role.find :all, :conditions=>"codename <> 'admin'"
    end  
    
    def [](key)
      c = self.cache
      c.read(key.to_s) || c.write(key.to_s, (Integer===key ? find(key) : find_by_codename(key.to_s)))
    end
  end
        
  def task_list
    (self.tasks || '').split ","
  end
  
  def cardname
    self.card.name
  end  

end
