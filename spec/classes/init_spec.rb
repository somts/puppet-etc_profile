require 'spec_helper'
# rubocop:disable Metrics/BlockLength
describe 'etc_profile', type: :class do
  shared_context 'Supported Platform' do
    it do should compile end
    it do
      should contain_class('etc_profile::install').that_comes_before(
        'Class[etc_profile::config]'
      )
    end
    it do should contain_class('etc_profile::config') end
  end

  shared_context 'FOSS' do
    it do should contain_file('/etc/profile.d').with_ensure('directory') end
    it do
      should contain_file('/etc/profile.d/pathmunge.sh').with_content(
        /\n\s+export PATH/
      ).that_requires('File[/etc/profile.d]')
    end
  end

  shared_context 'Darwin' do
    it do should compile end
    it do should_not contain_package('bash') end
    it do should_not contain_package('tcsh') end
    it do
      should contain_file('/private/etc/profile.d').with_ensure('directory')
    end
    it do
      should contain_file('/private/etc/profile.d/pathmunge.sh').with_content(
        /\n\s+export PATH/
      ).that_requires('File[/private/etc/profile.d]')
    end
    it do
      should contain_file('/private/etc/profile.d/pathmunge.csh').with_content(
        /\n\s+set path =/
      ).that_requires('File[/private/etc/profile.d]')
    end
    it do
      should contain_file('/private/etc/csh.login').with(
        ensure: 'file',
        content: /\nforeach p/
      )
    end
    it do
      should contain_file('/private/etc/profile').with(
        ensure: 'file',
        content: /\nfor i in/
      )
    end
  end

  shared_context 'Debian' do
    it do should contain_package('bash') end
    it do should contain_package('tcsh') end
    it do
      should contain_file('/etc/csh/login.d/pathmunge.csh').with_content(
        /\n\s+set path =/
      ).that_requires('File[/etc/csh/login.d]')
    end
  end

  shared_context 'FreeBSD' do
    it do should contain_package('bash') end
    it do should_not contain_package('tcsh') end
    it do
      should contain_file('/etc/csh.login').with(
        ensure: 'file',
        content: /\nforeach p/
      )
    end
    it do
      should contain_file('/etc/profile').with(
        ensure: 'file',
        content: /\nfor i in/
      )
    end
  end

  shared_context 'RedHat' do
    it do should contain_package('bash') end
    it do should contain_package('tcsh') end
  end

  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let :facts do
        os_facts
      end
      case os_facts[:osfamily]
      when 'Darwin' then
        it_behaves_like 'Supported Platform'
        it_behaves_like 'Darwin'
      when 'Debian' then
        it_behaves_like 'Supported Platform'
        it_behaves_like 'FOSS'
        it_behaves_like 'Debian'
      when 'FreeBSD' then
        it_behaves_like 'Supported Platform'
        it_behaves_like 'FOSS'
        it_behaves_like 'FreeBSD'
      when 'RedHat' then
        it_behaves_like 'Supported Platform'
        it_behaves_like 'FOSS'
        it_behaves_like 'RedHat'
      else
        it_behaves_like 'Unsupported Platform'
      end
    end
  end
end
# rubocop:enable Metrics/BlockLength
