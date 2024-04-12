# frozen_string_literal: true

require 'ipaddr'

Puppet::Functions.create_function(:"ipcalc::equal_to") do
  # Compare two IP addresses and return a Boolean indicating whether the left operand is equal to
  # the right.  This differs from comparing the address Strings in that it compares native 32-bit
  # (or for IPv6, 128-bit) binary values, regardless of their human-readable representations.  For
  # IPv4 addresses this is usually not much of a problem, as representations are simpler and
  # zero-padded values are relatively rare (enough that Stdlib::IP::Address::V4 filters them out as
  # invalid).  For IPv6 addresses, however, IPv6's collapsed notation can be a very serious problem,
  # and this function allows IPv6 addresses with un-collapsed runs of zeroes, leading zeroes, etc.
  # to be compared meaningfully without needing to worry about normalizing their human-readable
  # representations first.
  #
  # This will work with either plain addresses or CIDR-notation addresses.  If a plain address is
  # supplied, a full-width netmask is assumed; that is, '127.0.0.1' and '127.0.0.1/32' are
  # equivalent, just as 'fe80::1' and 'fe80::1/128' are equivalent.  The netmask is also assessed if
  # all bits of the address are equivalent; an address with a longer prefix is considered "larger."
  # Addresses of mixed families are always considered unequal.
  #
  # @param left
  #   The left address for comparison.  If no netmask is given, full-width is assumed.
  # @param right
  #   The right address for comparison.  If no netmask is given, full-width is assumed.
  # @return [Boolean]
  #   `true` if the operands are equal, or `false` otherwise.
  # @example Use with dotted function notation
  #   $left_ip.equal_to($right_ip) ? {
  #     true    => { 'We did it, go team, the operands are equal' },
  #     default => { 'I\'m afraid I have some bad news...' },
  #   }
  dispatch :equal_to do
    param 'Stdlib::IP::Address::V4', :left
    param 'Stdlib::IP::Address::V4', :right
    return_type 'Boolean'
  end

  dispatch :equal_to do
    param 'Stdlib::IP::Address::V6', :left
    param 'Stdlib::IP::Address::V6', :right
    return_type 'Boolean'
  end

  # We always consider mixed address families to be unequal.
  dispatch :mixed_families do
    param 'Stdlib::IP::Address::V4', :left
    param 'Stdlib::IP::Address::V6', :right
  end

  dispatch :mixed_families do
    param 'Stdlib::IP::Address::V6', :left
    param 'Stdlib::IP::Address::V4', :right
  end

  def normalize_addr(addr)
    # When initializing a new IPAddr, if a prefix length is given, the returned IPAddr will be the 
    # base network address and the subnet mask for that network, not the address that was passed 
    # in.  If we want to compare the full address, we need to separate the prefix and initialize a 
    # new IPAddr with the address alone, and then separately create an IPAddr instance to represent 
    # the network address.
    (address, prefix) = addr.split('/')
    ip_address = IPAddr.new(address)
    network_address = prefix ? IPAddr.new(addr) : ip_address
    [ip_address, network_address]
  end

  def equal_to(left, right)
    (left_addr, left_netaddr) = normalize_addr(left)
    (right_addr, right_netaddr) = normalize_addr(right)

    if left_addr == right_addr
      left_netaddr.prefix == right_netaddr.prefix
    else
      false
    end
  end

  def mixed_families(*)
    false
  end
end
