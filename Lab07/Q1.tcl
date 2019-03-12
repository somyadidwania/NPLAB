#Create a simulator object
set ns [new Simulator]

#Define different colors for data flows (for NAM)
$ns color 1 Blue
$ns color 2 Red

#Open the NAM trace file
set nf [open Q1_out.nam w]
$ns namtrace-all $nf

#Define a 'finish' procedure
proc finish {} {
    global ns nf
    $ns flush-trace
    #Close the NAM trace file
    close $nf
    #Execute NAM on the trace file
    exec nam Q1_out.nam &
    exit 0
}

#Create four nodes
set n0 [$ns node]
set n1 [$ns node]
set n2 [$ns node]
set n3 [$ns node]
set n4 [$ns node]

#Create links between the nodes
$ns duplex-link $n0 $n4 2Mb 10ms DropTail
$ns duplex-link $n1 $n4 2Mb 10ms DropTail
$ns duplex-link $n2 $n4 2Mb 10ms DropTail
$ns duplex-link $n3 $n4 2Mb 10ms DropTail

#Set Queue Size of link (n2-n3) to 10
$ns queue-limit $n4 $n3 10
$ns queue-limit $n4 $n2 10

#Give node position (for NAM)
$ns duplex-link-op $n4 $n0 orient left-down
$ns duplex-link-op $n4 $n1 orient left-up
$ns duplex-link-op $n4 $n2 orient right-up
$ns duplex-link-op $n4 $n3 orient right-down

#Monitor the queue for link (n2-n3). (for NAM)
$ns duplex-link-op $n4 $n3 queuePos 0.5
$ns duplex-link-op $n4 $n2 queuePos 0.5


#Setup a UDP connection
set udp [new Agent/UDP]
$ns attach-agent $n0 $udp
set null [new Agent/Null]
$ns attach-agent $n3 $null
$ns connect $udp $null
$udp set fid_ 1

#Setup a CBR over UDP connection
set cbr [new Application/Traffic/CBR]
$cbr attach-agent $udp
$cbr set type_ CBR
$cbr set packet_size_ 1000
$cbr set rate_ 1mb
$cbr set random_ false

#Schedule events for the CBR and FTP agents
$ns at 0.2 "$cbr start"
$ns at 8.5 "$cbr stop"

#Setup a UDP connection
set udp [new Agent/UDP]
$ns attach-agent $n1 $udp
set null [new Agent/Null]
$ns attach-agent $n2 $null
$ns connect $udp $null
$udp set fid_ 2

#Setup a CBR over UDP connection
set cbr [new Application/Traffic/CBR]
$cbr attach-agent $udp
$cbr set type_ CBR
$cbr set packet_size_ 1000
$cbr set rate_ 1mb
$cbr set random_ false

#Schedule events for the CBR and FTP agents
$ns at 0.1 "$cbr start"
$ns at 9.5 "$cbr stop"

#Detach tcp and sink agents (not really necessary)
#$ns at 4.5 "$ns detach-agent $n3 $sink"

#Call the finish procedure after 5 seconds of simulation time
$ns at 10.0 "finish"

#Print CBR packet size and interval
puts "CBR packet size = [$cbr set packet_size_]"
puts "CBR interval = [$cbr set interval_]"

#Run the simulation
$ns run