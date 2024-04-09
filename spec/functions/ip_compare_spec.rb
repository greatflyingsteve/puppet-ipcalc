# frozen_string_literal: true

require 'spec_helper'

describe 'ipcalc::ip_compare' do
  it { is_expected.to run.with_params('127.0.0.1', '127.0.0.2').and_return(-1) }
  it { is_expected.to run.with_params('127.0.0.1/32', '127.0.0.2/24').and_return(-1) }
  it { is_expected.to run.with_params('127.0.0.1/32', '127.0.0.1/24').and_return(1) }
  it { is_expected.to run.with_params('127.0.0.2', '127.0.0.1').and_return(1) }
  it { is_expected.to run.with_params('fe80::1', 'fe80::2').and_return(-1) }
  it { is_expected.to run.with_params('fe80::1/128', 'fe80::2/120').and_return(-1) }
  it { is_expected.to run.with_params('fe80::1/128', 'fe80::1/120').and_return(1) }
  it { is_expected.to run.with_params('fe80::2', 'fe80::1').and_return(1) }
  it { is_expected.to run.with_params(nil).and_raise_error(StandardError) }
  it { is_expected.to run.with_params('127.0.0.1', 'fe80::1').and_raise_error(StandardError) }
  it { is_expected.to run.with_params('fe80::1', '127.0.0.1').and_raise_error(StandardError) }
end
