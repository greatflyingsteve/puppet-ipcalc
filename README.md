ipcalc
======

## Description
This module provides puppet parser functions for performing IP address
calculations in manifests.

## Setup

To use this module, install it on your module path. No further setup is
necessary to use any of its features.

## Conventions

The functions in this module generally operate on strings that are constructed
from an IP address and either a subnet mask or a prefix length. Throughout the
documentation, strings in this format are refered to as an IP/CIDR. The suffix
supplies information about the address's subnet context. The following are
equivalent:

* 198.51.100.5/24
* 198.51.100.5/255.255.255.0

## Usage

These are the functions available in this module:

### `ip_address($cidr)`

ip_address takes an IP/CIDR and returns just the IP address.

### `ip_prefixlength($cidr)`

ip_prefixlength takes an IP/CIDR and returns just the prefix length.

### `ip_netmask($cidr)`

ip_netmask takes an IP/CIDR and returns the netmask which corresponds to its
prefix length.

### `ip_network($cidr, $offset)`

ip_network takes two arguments. The first is an IP/CIDR which is required. The
second is an optional numerical offset which defaults to 0. The function
returns an IP/CIDR by computing the network address of the subnet containing
the supplied IP/CIDR and incrementing it by the offset. Given no offset, the
function returns the network address for the subnet containing the supplied
IP/CIDR. The maximum reasonable value for offset is one less than the size of
the subnet containing the supplied IP/CIDR but the function will probably
accept larger values.

### `ip_broadcast($cidr, $offset)`

ip_broadcast takes two arguments. The first is an IP/CIDR which is required.
The second is an optional numerical offset which defaults to 0. The function
returns an IP/CIDR by computing the broadcast address of the subnet containing
the supplied IP/CIDR and decrementing it by the offset. Given no offset, the
function returns the broadcast address for the subnet containing the supplied
IP/CIDR. The maximum reasonable value for offset is one less than the size of
the subnet containing the supplied IP/CIDR but the function will probably
accept large values.

### `ip_increment($cidr, $offset)`

ip_increment takes two arguments. The first is an IP/CIDR which is required.
The second is an optional numerical increment which defaults to 1. The function
returns an IP/CIDR with the distance of `$offset` from the given IP/CIDR.

Example: `ip_increment('10.0.0.254/23',2)` will return `'10.0.1.0/23'`

### `ip_network_size($cidr)`

ip_network_size takes an IP/CIDR and returns the number of IP addresses
(including network and broadcast addresses) in the IP/CIDR's subnet.

### `ip_offset($cidr)`

ip_offset takes an IP/CIDR and returns its numerical offset. The offset is the
IP/CIDR's numerical distance from the beginning of its subnet at the network
address.

### `ip_split($cidr)`

ip_split takes an IP/CIDR and return an array containing the IP/CIDRs of the
top and bottom halves.

### `ip_subnet($cidr, $subnet_prefixlength, $index)`

ip_subnet returns a subnet of the given IP/CIDR. The subnet will have
`subnet_prefixlength` as its prefix length, and will be the `$index`th
such subnet in the given IP/CIDR

### `ip_supernet($cidr, $supernet_prefixlength)`

ip_supernet returns the IP/CIDR of size `$supernet_prefixlength` which contains
`$cidr`

### `ip_range_size($cidr_1, $cidr_2)`

ip_range_size takes a starting IP/CIDR and an ending IP/CIDR, and returns the
number of contiguious addresses between them, inclusive of the starting and
ending addresses.  Network size, network or broadcast addresses are NOT taken
into account, only the number of addresses of any type between start and end of
the range.

## Comparison Functions

The following functions are designed for use in comparing IP/CIDRs.  Unlike the
functions documented above, these are namespaced in this module and implemented
in the v4 API.

### `ipcalc::ip_compare($left_cidr, $right_cidr)`

ipcalc::ip_compare is designed to be used with Puppet's built-in `sort()`
function.  It takes two IP/CIDRs, and returns:
- `-1` if the left IP/CIDR is smaller than the right
- `0` if the left and right IP/CIDRs are equal
- `1` if the left IP/CIDR is greater than the right

When used in the optional block that can be passed to `sort()` (see examples in
the function's documentation), this allows `sort()` to sort an Array of IP
addresses into native order instead of string order - i.e., `1.1.1.2` will sort
lower than `1.1.1.10`, where string sorting would instead compare the first
seven characters, see `1.1.1.2` as greater than `1.1.1.1`, and sort them into
the wrong order.

### `ipcalc::greater_than($left_cidr, $right_cidr)`

Return `true` if the left IP/CIDR is greater than the right.  This makes the
most sense when using Puppet's dotted function notation:
```
$left_ip.ipcalc::greater_than($right_ip)
```

### `ipcalc::equal_or_greater_than($left_cidr, $right_cidr)`

Return `true` if the left IP/CIDR is equal-to-or-greater-than the right.  This
makes the most sense when using Puppet's dotted function notation:
```
$left_ip.ipcalc::equal_or_greater_than($right_ip)
```

### `ipcalc::equal_to($left_cidr, $right_cidr)`

Return `true` if the left and right IP/CIDRs are equal.  This makes the most
sense when using Puppet's dotted function notation:
```
$left_ip.ipcalc::less_than($right_ip)
```

### `ipcalc::equal_or_less_than($left_cidr, $right_cidr)`

Return `true` if the left IP/CIDR is equal-to-or-less-than the right.  This
makes the most sense when using Puppet's dotted function notation:
```
$left_ip.ipcalc::equal_or_less_than($right_ip)
```

### `ipcalc::less_than($left_cidr, $right_cidr)`

Return `true` if the left IP/CIDR is less than the right.  This makes the most
sense when using Puppet's dotted function notation:
```
$left_ip.ipcalc::less_than($right_ip)
```

