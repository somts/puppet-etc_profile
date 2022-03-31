require 'spec_helper'
describe 'etc_profile', type: :class do
  shared_examples 'Supported Platform' do
    it do
      is_expected.to create_class('etc_profile::install').that_comes_before(
        'Class[etc_profile::config]',
      )
    end
    it do is_expected.to create_class('etc_profile::config') end
    it do is_expected.to create_class('etc_profile::config::bourne') end
    it do is_expected.to create_class('etc_profile::config::cshell') end
    it do is_expected.to create_class('etc_profile::config::zshell') end

    ['bourne', 'cshell', 'zshell'].each do |i|
      context "when manage_#{i} == false" do
        let :params do
          { "manage_#{i}": false }
        end

        it do is_expected.not_to create_class("etc_profile::config::#{i}") end
      end
    end
  end

  shared_examples 'Linux Bourne (Again) shell' do
    # Linux /etc/profile setup is typically complex and its
    # best to let the OS's/package manager's defaults persist
    it do is_expected.not_to contain_file('/etc/profile') end

    it_behaves_like 'FreeBSD/Linux Bourne (Again) shell'
  end

  shared_examples 'Linux Berkeley UNIX C shell' do
    it do is_expected.to contain_package('tcsh') end
    it do is_expected.not_to contain_package('csh') end

    # Linux /etc/csh.* setup is typically complex and its
    # best to let the OS's/package manager's defaults persist
    ['cshrc', 'login', 'logout'].each do |i|
      it do is_expected.not_to contain_file("/etc/csh.#{i}") end
    end
  end

  shared_examples 'FreeBSD/Linux Bourne (Again) shell' do
    it do is_expected.to contain_package('bash') end
    it do
      is_expected.to contain_file('/etc/profile.d').with_ensure('directory')
    end
    it do
      is_expected.to contain_file('/etc/profile.d/pathmunge.sh').with_content(
        %r{\n\s+export PATH},
      )
    end
  end

  shared_examples 'Darwin' do
    it_behaves_like 'Supported Platform'
    it_behaves_like 'Darwin Bourne shell'
    it_behaves_like 'Darwin Berkeley UNIX C shell'
    it_behaves_like 'Darwin Z shell'
  end

  shared_examples 'Darwin Bourne shell' do
    it do is_expected.not_to contain_package('bash') end
    it do
      is_expected.to contain_file('/private/etc/profile.d').with_ensure(
        'directory',
      )
    end
    # Darwin ships with Bourne shell (not BASH) pre-installed
    it do
      is_expected.to contain_file('/private/etc/profile').with(
        ensure: 'file',
        content: %r{\nfor i in},
      )
    end
    it do
      is_expected.to contain_file(
        '/private/etc/profile.d/pathmunge.sh',
      ).with_content(%r{\n\s+export PATH})
    end
  end

  shared_examples 'Darwin Berkeley UNIX C shell' do
    it do is_expected.not_to contain_package('tcsh') end
    it do is_expected.not_to contain_package('csh') end
    it do
      is_expected.to contain_file(
        '/private/etc/profile.d/pathmunge.csh',
      ).with_content(%r{\n\s+set path =})
    end

    # Darwin /private/etc/csh.* setup is typically nothing, so manage
    ['cshrc', 'login', 'logout'].each do |i|
      it do
        is_expected.to contain_file("/private/etc/csh.#{i}").with(
          ensure: 'file',
          owner: 'root',
          group: 'wheel',
          mode: '0644',
          content: %r{^# Managed by Puppet etc_profile. DO NOT EDIT.\n},
        )
      end
    end
  end

  shared_examples 'Darwin Z shell' do
    it do is_expected.not_to contain_package('zsh') end
    ['zshenv', 'zprofile', 'zshrc', 'zlogin', 'zlogout'].each do |i|
      it do
        is_expected.to create_file("/private/etc/#{i}").with_ensure('file')
      end
      it do
        is_expected.to create_file(
          "/private/etc/zsh/#{i}.d",
        ).with_ensure('directory')
      end
      it do
        is_expected.to create_file_line("enable #{i}.d").with(
          path: "/private/etc/#{i}",
          line: "for i in /private/etc/zsh/#{i}.d/*.zsh(N); do source $i; done",
        ).that_requires("File[/private/etc/#{i}]")
      end
    end
  end

  shared_examples 'Debian' do
    it_behaves_like 'Supported Platform'
    it_behaves_like 'Linux Bourne (Again) shell'
    it_behaves_like 'Debian Berkeley UNIX C shell'
    it_behaves_like 'Debian Z shell'
  end

  shared_examples 'Debian Berkeley UNIX C shell' do
    it_behaves_like 'Linux Berkeley UNIX C shell'
    it do
      is_expected.to contain_file(
        '/etc/csh/cshrc.d/pathmunge.csh',
      ).with_content(%r{\n\s+set path =})
    end
  end

  shared_examples 'Linux Z shell' do
    it do is_expected.to contain_package('zsh') end
    it do
      is_expected.to create_file('/etc/zsh/zshenv.d/pathmunge.zsh').with(
        ensure: 'file',
        content: %r{# Managed by Puppet module etc_profile},
      ).that_requires('File[/etc/zsh/zshenv.d]')
    end
    ['zshenv', 'zprofile', 'zshrc', 'zlogin', 'zlogout'].each do |i|
      it do
        is_expected.to create_file("/etc/zsh/#{i}.d").with_ensure('directory')
      end
      it do
        is_expected.to create_file_line("enable #{i}.d").with_line(
          "for i in /etc/zsh/#{i}.d/*.zsh(N); do source $i; done",
        )
      end
    end
  end

  shared_examples 'Debian Z shell' do
    it_behaves_like 'Linux Z shell'
    ['zshenv', 'zprofile', 'zshrc', 'zlogin', 'zlogout'].each do |i|
      it do
        is_expected.to create_file("/etc/zsh/#{i}").with_ensure('file')
      end
      it do
        is_expected.to create_file_line("enable #{i}.d").with(
          path: "/etc/zsh/#{i}",
        ).that_requires("File[/etc/zsh/#{i}]")
      end
    end
  end

  shared_examples 'FreeBSD' do
    it_behaves_like 'Supported Platform'
    it_behaves_like 'FreeBSD Bourne (Again) shell'
    it_behaves_like 'FreeBSD Berkeley UNIX C shell'
    it_behaves_like 'FreeBSD Z shell'
  end

  shared_examples 'FreeBSD Bourne (Again) shell' do
    it do is_expected.to contain_package('bash') end
    # FreeBSD ships with Bourne shell (not BASH) pre-installed
    it do
      is_expected.to contain_file('/etc/profile').with(
        ensure: 'file',
        content: %r{\nfor i in},
      )
    end
    it_behaves_like 'FreeBSD/Linux Bourne (Again) shell'
  end

  shared_examples 'FreeBSD Berkeley UNIX C shell' do
    # FreeBSD comes with csh pre-installed and as the default shell
    it do is_expected.not_to contain_package('csh') end
    it do is_expected.not_to contain_package('tcsh') end

    # FreeBSD /etc/csh.* setup is typically nothing, so manage
    ['cshrc', 'login', 'logout'].each do |i|
      it do
        is_expected.to contain_file("/etc/csh.#{i}").with(
          ensure: 'file',
          owner: 'root',
          group: 'wheel',
          mode: '0644',
          content: %r{^# Managed by Puppet etc_profile. DO NOT EDIT.\n},
        )
      end
    end
  end

  shared_examples 'FreeBSD Z shell' do
    it do is_expected.to contain_package('zsh') end
    ['zshenv', 'zprofile', 'zshrc', 'zlogin', 'zlogout'].each do |i|
      it do
        is_expected.to create_file("/usr/local/etc/#{i}").with_ensure('file')
      end
      it do
        is_expected.to create_file(
          "/usr/local/etc/zsh/#{i}.d",
        ).with_ensure('directory')
      end
      it do
        is_expected.to create_file_line("enable #{i}.d").with(
          path: "/usr/local/etc/#{i}",
          line:
          "for i in /usr/local/etc/zsh/#{i}.d/*.zsh(N); do source $i; done",
        ).that_requires("File[/usr/local/etc/#{i}]")
      end
    end
  end

  shared_examples 'RedHat' do
    it_behaves_like 'Supported Platform'
    it_behaves_like 'Linux Bourne (Again) shell'
    it_behaves_like 'RedHat Berkeley UNIX C shell'
    it_behaves_like 'RedHat Z shell'
  end

  shared_examples 'RedHat Berkeley UNIX C shell' do
    it_behaves_like 'Linux Berkeley UNIX C shell'
    it do
      is_expected.to contain_file(
        '/etc/profile.d/pathmunge.sh',
      ).with_content(%r{\n\s+export PATH=})
    end
  end

  shared_examples 'RedHat Z shell' do
    it_behaves_like 'Linux Z shell'
    it do is_expected.to create_file('/etc/zshenv').with_ensure('file') end
    it do is_expected.to create_file('/etc/zprofile').with_ensure('file') end
    it do is_expected.to create_file('/etc/zshrc').with_ensure('file') end
    it do is_expected.to create_file('/etc/zlogin').with_ensure('file') end
    it do is_expected.to create_file('/etc/zlogout').with_ensure('file') end
    it do
      is_expected.to create_file_line('enable zshenv.d').with(
        path: '/etc/zshenv',
      ).that_requires('File[/etc/zshenv]')
    end
    it do
      is_expected.to create_file_line('enable zprofile.d').with(
        path: '/etc/zprofile',
      ).that_requires('File[/etc/zprofile]')
    end
    it do
      is_expected.to create_file_line('enable zshrc.d').with(
        path: '/etc/zshrc',
      ).that_requires('File[/etc/zshrc]')
    end
    it do
      is_expected.to create_file_line('enable zlogin.d').with(
        path: '/etc/zlogin',
      ).that_requires('File[/etc/zlogin]')
    end
    it do
      is_expected.to create_file_line('enable zlogout.d').with(
        path: '/etc/zlogout',
      ).that_requires('File[/etc/zlogout]')
    end
  end

  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let :facts do
        os_facts
      end

      it do is_expected.to compile.with_all_deps end
      case os_facts[:os]['family']
      when 'Darwin' then it_behaves_like 'Darwin'
      when 'Debian' then it_behaves_like 'Debian'
      when 'FreeBSD' then it_behaves_like 'FreeBSD'
      when 'RedHat' then it_behaves_like 'RedHat'
      end
    end
  end
end
