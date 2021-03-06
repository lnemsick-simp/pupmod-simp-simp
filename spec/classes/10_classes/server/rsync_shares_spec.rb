require 'spec_helper'

describe 'simp::server::rsync_shares' do
  context 'supported operating systems' do
    on_supported_os.each do |os, os_facts|
      context "on #{os}" do
        if os_facts[:kernel] == 'windows'
          let(:facts){ os_facts }
          it { expect{ is_expected.to compile.with_all_deps }.to raise_error(/'windows .+' is not supported/) }
        else
          let(:facts) do
            os_facts[:simp_rsync_environments] = {
              environment => {
                'id' => environment,
                'rsync' => {
                  'id' => 'rsync',
                  'global' => { 'id' => 'Global', 'shares' => ['clamav', 'jenkins_plugins', 'mcafee'] },
                  'centos' => {
                    'id'     => 'CentOS',
                    '7'      => { 'id' => '7',      'shares' => ['bind_dns'] },
                    '8'      => { 'id' => '8',      'shares' => ['bind_dns'] },
                    'global' => { 'id' => 'Global', 'shares' => ['apache', 'dhcpd', 'freeradius', 'snmp', 'tftpboot'] }
                  },
                  'redhat' => {
                    'id'     => 'RedHat',
                    '7'      => { 'id' => '7',      'shares' => ['bind_dns'] },
                    '8'      => { 'id' => '8',      'shares' => ['bind_dns'] },
                    'global' => { 'id' => 'Global', 'shares' => ['apache', 'dhcpd', 'freeradius', 'snmp', 'tftpboot'] }
                  },
                  'oraclelinux' => {
                    'id'     => 'OracleLinux',
                    '7'      => { 'id' => '7',      'shares' => ['bind_dns'] },
                    '8'      => { 'id' => '8',      'shares' => ['bind_dns'] },
                    'global' => { 'id' => 'Global', 'shares' => ['apache', 'dhcpd', 'freeradius', 'snmp', 'tftpboot'] }
                  }
                }
              }
            }

            os_facts
          end

          it { is_expected.to compile.with_all_deps }
          it { is_expected.to create_class('simp::server::rsync_shares') }
          it { is_expected.to create_rsync__server__section("clamav_#{environment}") }
          it { is_expected.to create_rsync__server__section("mcafee_#{environment}") }
          it { is_expected.to create_rsync__server__section("jenkins_plugins_#{environment}") }
          it { is_expected.to create_rsync__server__section("bind_dns_default_#{environment}_RedHat_7") }
          it { is_expected.to create_rsync__server__section("bind_dns_default_#{environment}_RedHat_8") }
          it { is_expected.to create_rsync__server__section("apache_#{environment}_RedHat") }
          it { is_expected.to create_rsync__server__section("tftpboot_#{environment}_RedHat") }
          it { is_expected.to create_rsync__server__section("dhcpd_#{environment}_RedHat") }
          it { is_expected.to create_rsync__server__section("snmp_#{environment}_RedHat") }
          it { is_expected.to create_rsync__server__section("freeradius_#{environment}_RedHat") }

          context 'with a limited share set' do
            let(:facts) do
              os_facts[:simp_rsync_environments] = {
                environment => {
                  'id' => environment,
                  'rsync' => {
                    'id' => 'rsync',
                    'global' => {
                      'id' => 'Global',
                      'shares' => [ 'clamav' ]
                    },
                    'redhat' => {
                      'id' => 'RedHat',
                      '7' => {
                        'id' => '7',
                        'shares' => [
                          'bind_dns'
                        ]
                      },
                      'global' => {
                        'id' => 'Global',
                        'shares' => [
                          'apache',
                          'tftpboot'
                        ]
                      }
                    }
                  }
                }
              }

              os_facts
            end

            it { is_expected.to compile.with_all_deps }
            it { is_expected.to create_class('simp::server::rsync_shares') }
            it { is_expected.to create_rsync__server__section("clamav_#{environment}") }
            it { is_expected.to_not create_rsync__server__section("mcafee_#{environment}") }
            it { is_expected.to_not create_rsync__server__section("jenkins_plugins_#{environment}") }
            it { is_expected.to create_rsync__server__section("bind_dns_default_#{environment}_RedHat_7") }
            it { is_expected.to_not create_rsync__server__section("bind_dns_default_#{environment}_RedHat_8") }
            it { is_expected.to create_rsync__server__section("apache_#{environment}_RedHat") }
            it { is_expected.to create_rsync__server__section("tftpboot_#{environment}_RedHat") }
            it { is_expected.to_not create_rsync__server__section("dhcpd_#{environment}_RedHat") }
            it { is_expected.to_not create_rsync__server__section("snmp_#{environment}_RedHat") }
            it { is_expected.to_not create_rsync__server__section("freeradius_#{environment}_RedHat") }
          end
        end
      end
    end
  end
end
