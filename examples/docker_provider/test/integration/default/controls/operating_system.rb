describe command('lsb_release -a') do its('stdout') { should match (/Ubuntu/) } end
