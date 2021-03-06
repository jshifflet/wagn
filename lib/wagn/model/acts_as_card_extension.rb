module Wagn::Model::ActsAsCardExtension

  def acts_as_card_extension( options = {})
    has_one :card_holder, :class_name=>'Card', :as=>:extension
    class_eval do
      def card
        return nil unless card_holder
        Card.fetch(card_holder.key, :skip_virtual=>true) || card_holder(force_reload=true)
      end
      
      def cardname
        (c = card) ? c.name : (
          respond_to?(:codename) ? codename : "#{self.class} #{self.id}"
        )
      end
    end
  end
end
