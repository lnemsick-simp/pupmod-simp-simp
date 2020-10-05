require 'spec_helper'

describe 'simp::yum::repo::simp_release_version' do
  context 'when version can be determined' do
    let(:pre_condition) { "function simplib::simp_version() { '6.5.0-0' }" }

    it { is_expected.to run.with_params('6').and_return('6') }
    it { is_expected.to run.with_params().and_return('6.5.0-0') }
  end

  context 'when version cannot be determined' do
    let(:pre_condition) { "function simplib::simp_version() { 'unknown' }" }
    let(:err_msg) { 'Unable to determine SIMP version automatically' }

    it { is_expected.to run.with_params().and_raise_error(/#{err_msg}/) }
  end

  context 'when version is a non-released version' do
    let(:simp_version) { '6.5.0-Alpha' }
    let(:pre_condition) { "function simplib::simp_version() { '#{simp_version}' }" }
    let(:err_msg) { "SIMP version #{simp_version} is not a released version" }

    it { is_expected.to run.with_params().and_raise_error(/#{err_msg}/) }
  end
end
