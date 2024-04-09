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
    param 'Stdlib::IP::Address::V4::Nosubnet', :left
    param 'Stdlib::IP::Address::V4::Nosubnet', :right
    return_type 'Integer[-1, 1]'
  end

  dispatch :ip_compare do
    param 'Stdlib::IP::Address::V6::Nosubnet', :left
    param 'Stdlib::IP::Address::V6::Nosubnet', :right
    return_type 'Integer[-1, 1]'
  end

  # If we're passed a CIDR address with an attached netmask, normalize this so we compare all bits
  # of the address portion.  We need to handle mask length comparison separately, and only if the
  # address bits are identical.
  dispatch :normalize_netaddrs do
    param 'Stdlib::IP::Address::V4::CIDR', :left
    param 'Stdlib::IP::Address::V4::CIDR', :right
    return_type 'Integer[-1, 1]'
  end

  dispatch :normalize_netaddrs do
    param 'Stdlib::IP::Address::V6::CIDR', :left
    param 'Stdlib::IP::Address::V6::CIDR', :right
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

  def normalize_netaddrs(left, right)
    left_netaddr = IPAddr.new(left)
    right_netaddr = IPAddr.new(right)

    ip_compare(left.split('/')[0], right.split('/')[0], left_netaddr, right_netaddr)
  end

  def ip_compare(left, right, left_netaddr = IPAddr.new(left), right_netaddr = IPAddr.new(right))
    left_addr = IPAddr.new(left)
    right_addr = IPAddr.new(right)

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
