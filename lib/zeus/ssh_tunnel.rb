# frozen_string_literal: true

# === Example
# Zeus::SshTunnel.link('root@db-01', '5555:localhost:5432') do
#   system('telnet localhost 5555')
# end
module Zeus
  class SshTunnel
    def self.link(remote, destination)
      IO.popen("ssh -N #{remote} -L #{destination}") do |pipe|
        pipe.read # just like wait
        yield
      end
    end
  end
end
