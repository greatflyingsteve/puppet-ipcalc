# frozen_string_literal: true

require 'ipaddr'

Puppet::Functions.create_function(:"ipcalc::ip_compare") do
  # Compare two IP addresses and return a `sort()`-compatible Integer comparison result.
  #
  # This will work with either plain addresses or CIDR-notation addresses; if a plain address is
  # supplied, a full-width netmask is assumed.  That is, '127.0.0.1' and '127.0.0.1/32' are
  # equivalent, just as 'fe80::1' and 'fe80::1/128' are equivalent.  The netmask is also assessed if
  # all bits of the address are equivalent; an address with a longer prefix is considered "larger."
  #
  # @param left
  #   The left address for comparison.  If no netmask is given, a full-width mask is assumed.
  # @param right
  #   The right address for comparison.  If no netmask is given, a full-width mask is assumed.
  # @return [Integer[-1, 1]]
  #   Either 1, 0, or -1 if the left operand is larger than, equal to, or smaller than the right,
  #   respectively.
  # @example Usage with `sort()`
  #   $my_addr_array.sort |$left, $right| {
  #     ipcalc::ip_compare($left, $right)
  #   }
  dispatch :ip_compare do
    param 'Stdlib::IP::Address::V4', :left
    param 'Stdlib::IP::Address::V4', :right
    return_type 'Integer[-1, 1]'
  end

  dispatch :ip_compare do
    param 'Stdlib::IP::Address::V6', :left
    param 'Stdlib::IP::Address::V6', :right
    return_type 'Integer[-1, 1]'
  end

  # We refuse to handle addresses in different families.  There isn't a clear precedence between
  # them, and if needed, any relative ordering required can be handled in your Puppet code by
  # assessing the types handed to `sort()`.  There are examples of this in the documentation for the
  # Puppet `sort()` function, but a specific example for sorting all IPv6 addresses before all IPv4
  # address is included for reference.
  # @example Usage with `sort()` where IPv6 sorts above IPv4
  #   $my_ip_array.sort |$left, $right| {
  #     case [$left, $right] {
  #       [Stdlib::IP::Address::V6, Stdlib::IP::Address::V4]: { 1 }
  #       [Stdlib::IP::Address::V4, Stdlib::IP::Address::V6]: { -1 }
  #       default:                                            { ipcalc::ip_compare($left, $right) }
  #     }
  #   }
  argument_mismatch :mixed_families do
    param 'Stdlib::IP::Address::V4', :left
    param 'Stdlib::IP::Address::V6', :right
  end

  argument_mismatch :mixed_families do
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

  def ip_compare(left, right)
    (left_addr, left_netaddr) = normalize_addr(left)
    (right_addr, right_netaddr) = normalize_addr(right)

    if left_addr == right_addr
      left_netaddr.prefix <=> right_netaddr.prefix
    else
      left_addr <=> right_addr
    end
  end

  def mixed_families(*)
    'both addresses must be in the same family'
  end
end
