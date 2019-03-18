# Copyright (c) 2012 National ICT Australia Limited (NICTA).
# This software may be used and distributed solely under the terms of the MIT license (License).
# You should find a copy of the License in LICENSE.TXT or at http://opensource.org/licenses/MIT.
# By downloading or using this software you accept the terms and the liability disclaimer in the License.

require 'test_helper'
require 'omf_rc/resource_proxy_dsl'

describe OmfRc::ResourceProxyDSL do
  before do
    mock_comm_in_res_proxy
    mock_topics_in_res_proxy(resources: [:mp0, :mrp0, :up0, :f0])

    module OmfRc::Util::MockUtility
      include OmfRc::ResourceProxyDSL

      property :mock_prop, default: 1
      property :read_only_prop, default: 1, access: :read_only
      property :init_only_prop, default: 1, access: :init_only

      configure :alpha

      request :alpha do |resource|
        resource.uid
      end

      work :bravo do |resource, *random_arguments, block|
        if block
          block.call("working on #{random_arguments.first}")
        else
          random_arguments.first
        end
      end

      request :zulu do |resource, options|
        "You called zulu with: #{options.keys.join('|')}"
      end

      request :xray, if: proc { false } do
        "This property would NOT be registered"
      end
    end

    module OmfRc::ResourceProxy::MockRootProxy
      include OmfRc::ResourceProxyDSL

      register_proxy :mock_root_proxy
    end

    module OmfRc::ResourceProxy::MockProxy
      include OmfRc::ResourceProxyDSL

      register_proxy :mock_proxy, :create_by => :mock_root_proxy

      utility :mock_utility

      hook :before_ready
      hook :before_release

      bravo("printing") do |v|
        request :charlie do
          v
        end
      end

      request :delta do
        bravo("printing")
      end
    end

    module OmfRc::ResourceProxy::UselessProxy
      include OmfRc::ResourceProxyDSL

      register_proxy :useless_proxy
    end

    module OmfRc::ResourceProxy::Foo
      include OmfRc::ResourceProxyDSL

      register_proxy :foo

      namespace :foo, "http://schema/foo"
    end
  end

  after do
    unmock_comm_in_res_proxy
  end

  describe "when included by modules to define resource proxy functionalities" do
    it "must be able to register the modules" do
      OmfRc::ResourceFactory.proxy_list.must_include :mock_proxy
    end

    it "must be able to define methods" do
      %w(configure_alpha request_alpha bravo).each do |m|
        OmfRc::Util::MockUtility.method_defined?(m.to_sym).must_equal true
      end

      %w(configure_alpha request_alpha before_ready before_release bravo).each do |m|
        OmfRc::ResourceProxy::MockProxy.method_defined?(m.to_sym).must_equal true
      end

      mock_proxy = OmfRc::ResourceFactory.create(:mock_proxy, uid: :mp0)
      mock_proxy.request_alpha.must_equal mock_proxy.uid
      mock_proxy.request_delta.must_equal "printing"
      mock_proxy.request_charlie.must_equal "working on printing"
      mock_proxy.bravo("magic", "second parameter") do |v|
        v.must_equal "working on magic"
      end
      mock_proxy.bravo("something", "something else").must_equal "something"
      mock_proxy.request_zulu(country: 'uk').must_equal "You called zulu with: country"
    end

    it "wont define methods when restriction provided and failed to meet" do
      begin
        mock_proxy = OmfRc::ResourceFactory.create(:mock_proxy, uid: :mp0)
        mock_proxy.request_xray
      rescue => e
        e.must_be_kind_of NoMethodError
        e.message.must_match /request_xray/
      end
    end

    it "must be able to include utility" do
      Class.new do
        include OmfRc::ResourceProxyDSL
        utility :mock_utility
      end.new.must_respond_to :request_alpha
    end

    it "must log error if utility can't be found" do
      Class.new do
        include OmfRc::ResourceProxyDSL
        utility :wont_be_found_utility
        stub :require, true do
          utility :wont_be_found_utility
        end
      end
    end

    it "must check new proxy's create_by option when ask a proxy create a new proxy" do
      OmfRc::ResourceFactory.create(:mock_root_proxy, uid: :mrp0).create(:mock_proxy, uid: :mp0)
      OmfRc::ResourceFactory.create(:mock_root_proxy, uid: :mrp0).create(:useless_proxy, uid: :up0)
      lambda { OmfRc::ResourceFactory.create(:useless_proxy, uid: :mrp0).create(:mock_proxy, uid: :mp0) }.must_raise StandardError
    end

    it "must be able to define property with default vlaue" do
      mock_proxy = OmfRc::ResourceFactory.create(:mock_proxy, uid: :mp0)
      mock_proxy.property.mock_prop.must_equal 1
      mock_proxy.request_mock_prop.must_equal 1
      mock_proxy.configure_mock_prop(2)
      mock_proxy.request_mock_prop.must_equal 2
    end


    it "must define associate methods when access option given to property definition" do
      mock_proxy = OmfRc::ResourceFactory.create(:mock_proxy, uid: :mp0)
      # Ready only
      mock_proxy.request_read_only_prop.must_equal 1
      lambda { mock_proxy.init_read_only_prop }.must_raise NoMethodError
      lambda { mock_proxy.configure_read_only_prop }.must_raise NoMethodError
      # Init only
      mock_proxy.request_init_only_prop.must_equal 1
      lambda { mock_proxy.init_init_only_prop }.must_raise NoMethodError
      lambda { mock_proxy.configure_init_only_prop }.must_raise NoMethodError
    end
  end

  describe "when namespace specified" do
    it "must define namespace in the resource proxy" do
      foo = OmfRc::ResourceFactory.create(:foo, uid: :f0)
      foo.namespace.must_equal({foo: "http://schema/foo"})
    end
  end
end
