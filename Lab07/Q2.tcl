#Create a simulator object
set ns [new Simulator]
#$ns rtproto LS
#Define different colors for data flows (for NAM)
$ns color 1 Blue
$ns color 2 Green

#Open the NAM trace file
set nf [open Q2_out.nam w]
$ns namtrace-all $nf

#Define a 'finish' procedure
proc finish {} {
    global ns nf
    $ns flush-trace
    #Close the NAM trace file
    close $nf
    #Execute NAM on the trace file
    exec nam Q2_out.nam &
    exit 0
}


#Create four nodes
set n0 [$ns node]
set n1 [$ns node]
set n2 [$ns node]
set n3 [$ns node]

#Create links between the nodes
$ns duplex-link $n0 $n1 1Mb 10ms DropTail
$ns duplex-link $n2 $n3 1Mb 10ms DropTail
$ns duplex-link $n0 $n3 1Mb 10ms DropTail
$ns duplex-link $n2 $n1 1Mb 10ms DropTail
#$ns duplex-link $n2 $n3 1.7Mb 20ms DropTail

#Set Queue Size of link (n2-n3) to 10
$ns queue-limit $n2 $n3 10
$ns queue-limit $n0 $n1 10

#Give node position (for NAM)
$ns duplex-link-op $n0 $n3 orient right
$ns duplex-link-op $n3 $n2 orient down
$ns duplex-link-op $n2 $n1 orient left
$ns duplex-link-op $n1 $n0 orient up

#Monitor the queue for link (n2-n3). (for NAM)
$ns duplex-link-op $n2 $n3 queuePos 0.5
$ns duplex-link-op $n0 $n1 queuePos 0.5

#Setup a TCP connection
set tcp [new Agent/TCP]
$tcp set class_ 2
$ns attach-agent $n0 $tcp
set sink [new Agent/TCPSink]
$ns attach-agent $n1 $sink
$ns connect $tcp $sink
$tcp set fid_ 1

#Setup a FTP over TCP connection
set ftp [new Application/FTP]
$ftp attach-agent $tcp
$ftp set type_ FTP

set tcp [new Agent/TCP]
$tcp set class_ 2
$ns attach-agent $n2 $tcp
set sink [new Agent/TCPSink]
$ns attach-agent $n3 $sink
$ns connect $tcp $sink
$tcp set fid_ 2

#Setup a FTP over TCP connection
set ftp1 [new Application/FTP]
$ftp1 attach-agent $tcp
$ftp1 set type_ FTP

$ns rtmodel-at 2.0 down $n0 $n1
$ns rtmodel-at 2.2 up $n0 $n1

$ns at 0.1 "$ftp start"
$ns at 4.5 "$ftp stop"
$ns at 1.0 "$ftp1 start"
$ns at 5.0 "$ftp1 stop"
#Detach tcp and sink agents (not really necessary)
$ns at 4.5 "$ns detach-agent $n0 $tcp ; $ns detach-agent $n1 $sink;$ns detach-agent $n2 $tcp ; $ns detach-agent $n3 $sink;"

#Call the finish procedure after 5 seconds of simulation time
$ns at 5.0 "finish"

#Print CBR packet size and interval
#puts "CBR packet size = [$cbr set packet_size_]"
#puts "CBR interval = [$cbr set interval_]"

#Run the simulation
$ns run