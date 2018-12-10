# Copyright (c) 2012 National ICT Australia Limited (NICTA).
# This software may be used and distributed solely under the terms of the MIT license (License).
# You should find a copy of the License in LICENSE.TXT or at http://opensource.org/licenses/MIT.
# By downloading or using this software you accept the terms and the liability disclaimer in the License.

require 'facter'

# This module defines a Utility with some common work blocks that could be
# useful to any type of Resource Proxy (RP)
#
module OmfRc::Util::CommonTools
  include OmfRc::ResourceProxyDSL

  # This utility block logs an error/warn String S on the resource proxy side
  # and publish an INFORM message on the resources pubsub topic. This INFORM
  # message will have the type ERROR/WARN, and its 'reason' element set to the
  # String S
  #
  # @yieldparam [String] msg the error or warning message
  #
  %w(error warn).each do |type|
    work("log_inform_#{type}") do |res, msg|
      res.send(type, msg, res.uid)
      res.topics.first.inform(type.to_sym,
                              { reason: msg },
                              { src: res.resource_address })
    end
  end

  work :execute_cmd do |res, cmd, intro_msg, error_msg, success_msg|
    logger.info "#{intro_msg} with: '#{cmd}'"
    result = `#{cmd} 2>&1`
    if $?.exitstatus != 0
      res.log_inform_error "#{error_msg}: '#{result}'"
      result.strip
    else
      logger.info "#{success_msg}"
      result.strip
    end
  end

  # This utility block returns true if its given value parameter is a Boolean,
  # which in Ruby means that it is either of the class TrueClass or FalseClass
  #
  # @yieldparam [Object] obj the Object to test as Boolean
  #
  # [Boolean] true or fals
  #
  work('boolean?') do |res, obj|
    result = false
    result = true if obj.kind_of?(TrueClass) || obj.kind_of?(FalseClass)
    result
  end

  def cmd_exists?(cmd)
    !Facter::Core::Execution.which(cmd).nil?
  end
end
