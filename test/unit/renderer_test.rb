require File.dirname(__FILE__) + '/../test_helper'

#
# Note that we are using stub rendering here to get links.  This isn't really a very good
# test because it has a very special code path that is really very limited.  It gets
# internal links expanded in html or xml style, and prety much ignores any other output.
#
class Wagn::RendererTest < ActiveSupport::TestCase
  include ChunkTestHelper
  
  #attr_accessor :controller

  def setup
    setup_default_user     
  end

  def test_replace_references_should_work_on_inclusions_inside_links       
    card = Card.create!(:name=>"test", :content=>"[[test{{test}}]]"  )    
    assert_equal "[[test{{best}}]]", Wagn::Renderer.new(card).replace_references( "test", "best" )
  end

  def controller
    return @controller if @controller
    @controller = CardController.new()
#raise "App controller not created" unless @controller
    @controller
  end

  def slot_link(card, format=:html)
    render = Wagn::Renderer.new(card, :context=>"nocontext", :format=>format).render(:content)
    m = render.match(/<(cardref|link|a) class.*<\/(cardref|link|a)>/)
Rails.logger.info("slot_link(#{card.name},#{card.class}) #{m}, #{m.inspect} R:#{render}")
    (m.to_s != "") ? m.to_s : render
  end

  def test_slot_render
    card = newcard('Baines', '[[Nixon]]')
    assert_equal '<a class="wanted-card" href="/wagn/Nixon">Nixon</a>', slot_link(card)

    lbj_link = '<a class="known-card" href="/wagn/Baines">Lyndon</a>'
    
    card2 = newcard('Johnson', '[Lyndon][Baines]')
    assert_equal(lbj_link, slot_link(card2))
    
    card2.content = '[[Baines|Lyndon]]'; card2.save
    assert_equal(lbj_link, slot_link(card2))
    
  end

  def test_slot_relative_card
    cardA = newcard('Kennedy', '[[+Monroe]]')
    assert_equal '<a class="wanted-card" href="/wagn/Kennedy%2BMonroe">+Monroe</a>', slot_link(cardA)

    cardB = newcard('Clinton', '[[Lewinsky+]]')
    assert_equal '<a class="wanted-card" href="/wagn/Lewinsky%2BClinton">Lewinsky+</a>', slot_link(cardB)
  end

  def test_slot_relative_url
    card3 = newcard('recent changes', '[[/recent|Recent]]')
    assert_equal '<a class="internal-link" href="/recent">Recent</a>', slot_link(card3)
    card3 = newcard('rc2', '[[/recent]]')
    assert_equal '<a class="internal-link" href="/recent">/recent</a>', slot_link(card3)
  end
  
  def test_slot_external
    card4 = newcard('google link', '[[http://google.com]]')
    assert_equal '<a class="external-link" href="http://google.com">http://google.com</a>', slot_link(card4)
  end
  
  def internal_needs_escaping    
    card5 = newcard('userlink', '[Marie][Marie "Mad Dog" Deatherage]')
    assert_equal '<a class="wanted-card" href="/wagn/Marie_%22Mad_Dog%22_Deatherage">Marie</a>', slot_link(card5)
  end
     
  def external_needs_not_escaped
    card6 = newcard('google link2', 'wgw&nbsp; [google][http://www.google.com] &nbsp;  <br>')
    assert_equal "wgw&nbsp; <a class=\"wanted-card\" href=\"http://www.google.com\">google</a> &nbsp;  <br>", slot_link(card6)
  end
  
#  def test_relative_link
#    dude,job = newcard('Harvey',"[[#{JOINT}business]]"), newcard('business')
#ActionController::Base.logger.info("ERROR:INFO:newcard is nil: Harvey") unless dude
#ActionController::Base.logger.info("ERROR:INFO:newcard is nil: +business") unless job
#    card = dude.connect job, "icepicker" 
#ActionController::Base.logger.info("ERROR:INFO:newcard is nil: Harvey+business") unless card
#    assert_equal "<a class=\"known-card\" href=\"/wagn/Harvey+business\">#{JOINT}business</a>", slot_link(dude)
#  end
  
end                                                                      
