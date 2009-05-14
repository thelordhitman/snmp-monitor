#!/usr/bin/env ruby

# You might want to change this
ENV["RAILS_ENV"] ||= "production"

require File.dirname(__FILE__) + "/../../config/environment"

$running = true
Signal.trap("TERM") do 
  $running = false
end

while($running) do  
	m = SNMP::TrapListener.new do |manager|
	  manager.on_trap_default do |snmptrap|
	  	Rails.logger.info "Trap Received\n#{snmptrap}\n"
	    Trap.create!(
	    							:uptime => snmptrap.sys_up_time,
	    							:oid => snmptrap.trap_oid,
	    							:agent_id => Agent.find_by_ip_address(snmptrap.source_ip)
	    						)
	  end
	end
	m.join
end