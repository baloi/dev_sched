ENV["RAILS_ENV"] = "test"
require File.expand_path(File.dirname(__FILE__) + "/../config/environment")
require 'test_help'

#baloi start
I_KNOW_I_AM_USING_AN_OLD_AND_BUGGY_VERSION_OF_LIBXML2  = true

require 'redgreen'
#require 'webrat'
require 'nokogiri'
require 'calendar'
#require 'rack/test'
require 'mocha'

#include Webrat::Methods 
#include Webrat::Matchers 


#Webrat.configure do |config|
#  config.mode = :rails
  #config.mode = :rack
#end

#baloi end

class Test::Unit::TestCase
  # Transactional fixtures accelerate your tests by wrapping each test method
  # in a transaction that's rolled back on completion.  This ensures that the
  # test database remains unchanged so your fixtures don't have to be reloaded
  # between every test method.  Fewer database queries means faster tests.
  #
  # Read Mike Clark's excellent walkthrough at
  #   http://clarkware.com/cgi/blosxom/2005/10/24#Rails10FastTesting
  #
  # Every Active Record database supports transactions except MyISAM tables
  # in MySQL.  Turn off transactional fixtures in this case; however, if you
  # don't care one way or the other, switching from MyISAM to InnoDB tables
  # is recommended.
  self.use_transactional_fixtures = true

  # Instantiated fixtures are slow, but give you @david where otherwise you
  # would need people(:david).  If you don't want to migrate your existing
  # test cases which use the @david style and don't mind the speed hit (each
  # instantiated fixtures translates to a database query per test method),
  # then set this back to true.
  self.use_instantiated_fixtures  = false

  # Add more helper methods to be used by all tests here...

  # baloi start

  def self.must(name, &block)
    test_name = "test_#{name.gsub(/\s+/,'_')}.to_sym
    defined = instance_method(test_name) rescue false
    raise "#{test_name} is already defined in #{self}" if defined
    if block_given?
      define_method(test_name, &block)
    else
      define_method(test_name) do
        flunk "No implementation provided for #{name}"
      end
    end
  end

  def contains_data(data_array, str_to_search)
    data_array.each do |d|
      #puts "d = #{d.methods}"
      pattern = Regexp.new(str_to_search)
      #if d =~ pattern 
      if pattern.match(d.to_s)
        return true
      #else
      #  puts "#{d} does not match #{pattern}"
      end
    end
    return false
  end

  def find_in_html(html, tag, id)
    html_doc = Nokogiri.HTML(html)
    element_description = "//#{tag}[@id='#{id}']"
    element = html_doc.xpath(element_description)
    n = element.children.first.to_s

  end

  def set_rehab_day(rehab_day)
    @request.session[:rehab_day_id] = rehab_day.id
  end
  # baloi end

end

module Test::Unit
  class TestCase
  end
end
