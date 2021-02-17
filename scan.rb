#! /usr/bin/ruby
require 'socket'

class Scanner

	def initialize (ports = [21,22,23,25,53,80,443,3306,8080], host = "localhost")
		super()
		print " ######\n"
		print " ### port scanner by @f4nt0ch\n"
		print " ######\n"
		print "\n"

		@delimiters = [',', '.', ' ', '/']
		@commands = {
			'set host': ["set_host", " host ip or uri to scan"],
			'set port': ["set_ports", " port/s to scan (ex: 22, or multi ex: 21,22,23)"],
			'set hosts': ["set_host", " host ip or uri to scan"],
			'set ports': ["set_ports", " port/s to scan (ex: 22, or multi ex: 21,22,23)"],
			'run': ["run", " execute scan"],
			'help': ["help", " execute scan"],
			'scan': ["run", " execute scan"],
			'option': ["show_options", " show setted configuration"],
			'options': ["show_options", " show setted configuration"],
			'show options': ["show_options", " show setted configuration"]
		}

		@timeout = 2
		@ports = ports
		@host = host

		ARGV.clear
		self.cmd
	end

	def prompt(*args)
		print(*args)
		gets.chomp
	end

	def show_options
		print " ------  host   => #{@host} \n"
		print " ------  port/s => #{@ports} \n"
	end

	def cmd
		begin
			val = prompt "> "
			if @commands.key?(:"#{val}")
				self.send(@commands[:"#{val}"][0].to_s)
			else
				print "\n"
				print " Command not found : #{val}"
				self.help
			end
			self.cmd
		rescue SystemExit, Interrupt
			exit 0
		rescue Exception => e
			raise e
		end
	end

	def help
		print " -allowed commands : \n".to_s
		@commands.each { |key, value| print "\n   #{key} => #{value[1]}" }
		print "\n"
		self.cmd
	end

	def set_host
		@host = gets.chomp
	end

	def set_ports
		@ports = gets.chomp.split(Regexp.union(@delimiters)).map(&:to_i)
	end

	def run
		threads = []
		puts "\n START SCAN => #{@host}"
		begin
			@ports.each_with_index { |i, index| threads << Thread.new {
				socket = Socket.new Socket::AF_INET, Socket::SOCK_STREAM
				addr = Socket.sockaddr_in(i, @host)

				begin
					puts "\n" if index == 0
					puts "Port #{i} is open." if socket.connect(addr)
				rescue Errno::EINPROGRESS, Errno::ECONNREFUSED
					puts "Port #{i} is closed."
				end
				socket.close
			}}
			self.cmd
		rescue NoMethodError => e
			if @ports.is_a? Integer
				@ports = [@ports]
				run()
			else
				puts "\n/!\\ '#{@ports}' Cannot be a port ! \n"
			end
		end
	end

end

HOST = ARGV[0] || 'localhost'
PORT = ARGV[1] || 22

Scanner.new PORT, HOST