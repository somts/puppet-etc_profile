require 'spec_helper'

describe 'etc_profile::config::bourne' do
  on_supported_os.each do |os, os_facts|
    context "on #{os} " do
      let :facts do
        os_facts
      end

      context 'with all defaults' do
        it do
          is_expected.to compile.and_raise_error(
            %r{Must only be called by etc_profile},
          )
        end
      end
    end
  end
end
