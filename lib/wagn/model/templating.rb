module Wagn::Model::Templating  

  def template?()       name && name.template_name?        end
  def hard_template?()  name && name =~ /\+\*content$/     end
  def soft_template?()  name && name =~ /\*default$/       end
  def type_template?()  template? && name =~ /\+\*type\+/  end
  def right_template?() template? && name =~ /\+\*right\+/ end

  def template(reset = false)
    @template = reset ? setting_card('content','default') : (@template || setting_card('content','default'))
#    @template ||= setting_card('content','default')
  end
  def right_template()   (template && template.right_template?) ? template : nil  end
  def hard_template()    (template && template.hard_template?)  ? template : nil  end
  def content_template() hard_template                                            end

  def templated_content
    return unless template && template.hard_template?
    template.content
  end

  def hard_templatees
    if wql=hard_templatee_wql
      User.as(:wagbot)  {  Wql.new(wql).run  }
    else
      []
    end
  end    

  # FIXME: content settings -- do we really need the reference expiration system?
  def expire_templatee_references
    return unless respond_to?('references_expired')
    if wql=hard_templatee_wql
      condition = User.as(:wagbot) { Wql::CardSpec.build(wql.merge(:return=>"condition")).to_sql }
      card_ids_to_update = connection.select_rows("select id from cards t where #{condition}").map(&:first)
      card_ids_to_update.each_slice(100) do |id_batch|
        connection.execute "update cards set references_expired=1 where id in (#{id_batch.join(',')})"
      end
    end
  end

  private
  # FIXME: remove after adjusting expire_templatee_references to content_settings
  def hard_templatee_wql
    if hard_template? and c=Card.fetch(name.trunk_name) and c.typecode == 'Set'
      wql = c.get_spec
    end
  end

end
