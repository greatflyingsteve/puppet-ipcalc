# frozen_string_literal: true

require 'ipaddr'

Puppet::Functions.create_function(:"ipcalc::less_than") do
  # Compare two IP addresses and return a Boolean indicating whether the left operand is less than
  # the right.
  #
  # This will work with either plain addresses or CIDR-notation addresses.  If a plain address is
  # supplied, a full-width netmask is assumed; that is, '127.0.0.1' and '127.0.0.1/32' are
  # equivalent, just as 'fe80::1' and 'fe80::1/128' are equivalent.  The netmask is also assessed if
  # all bits of the address are equivalent; an address with a longer prefix is considered "larger."
  # If addresses of mixed families are given, an error is raised and the catalog will fail.  There
  # is no obvious implied relation between the two, and even the underlying Ruby implementation will
  # refuse to make comparisons between addresses of different families.
  #
  # @param left
  #   The left address for comparison.  If no netmask is given, full-width is assumed.
  # @param right
  #   The right address for comparison.  If no netmask is given, full-width is assumed.
  # @return [Boolean]
  #   `true` if the left operand is less than the right, or `false` otherwise.
  # @example Use with dotted function notation
  #   $left_ip.less_than($right_ip) ? {
  #     true    => { 'We did it, go team, left operand is smaller' },
  #     default => { 'I\'m afraid I have some bad news...' },
  #   }
  dispatch :less_than do
    param 'Stdlib::IP::Address::V4::Nosubnet', :left
    param 'Stdlib::IP::Address::V4::Nosubnet', :right
    return_type 'Boolean'
  end

  dispatch :less_than do
    param 'Stdlib::IP::Address::V6::Nosubnet', :left
    param 'Stdlib::IP::Address::V6::Nosubnet', :right
    return_type 'Boolean'
  end

  # If we're passed a CIDR address with an attached netmask, normalize this so we compare all bits
  # of the address portion.  We need to handle mask length comparison separately, and only if the
  # address bits are identical.
  dispatch :normalize_netaddrs do
    param 'Stdlib::IP::Address::V4::CIDR', :left
    param 'Stdlib::IP::Address::V4::CIDR', :right
    return_type 'Boolean'
  end

  dispatch :normalize_netaddrs do
    param 'Stdlib::IP::Address::V6::CIDR', :left
    param 'Stdlib::IP::Address::V6::CIDR', :right
    return_type 'Boolean'
  end

  # Refuse to handle addresses in different families.  There isn't a clear precedence between the
  # two families; if you need to establish an order, you can use type comparison to handle this in
  # your Puppet code.
  argument_mismatch :mixed_families do
    param 'Stdlib::IP::Address::V4', :left
    param 'Stdlib::IP::Address::V6', :right
  end

  argument_mismatch :mixed_families do
    param 'Stdlib::IP::Address::V6', :left
    param 'Stdlib::IP::Address::V4', :right
  end

  def normalize_netaddrs(left, right)
    left_netaddr = IPAddr.new(left)
    right_netaddr = IPAddr.new(right)

    less_than(left.split('/')[0], right.split('/')[0], left_netaddr, right_netaddr)
  end

  def less_than(left, right, left_netaddr = IPAddr.new(left), right_netaddr = IPAddr.new(right))
    left_addr = IPAddr.new(left)
    right_addr = IPAddr.new(right)

    if left_addr == right_addr
      left_netaddr.prefix < right_netaddr.prefix
    else
      left_addr < right_addr
    end
  end

  def mixed_families(*)
    'both addresses must be in the same family'
  end
end
