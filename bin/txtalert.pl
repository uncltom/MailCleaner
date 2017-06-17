#!/usr/bin/perl -w
#
#  Addition to mailcleaner to report mail not being delivered.
#  $to should be the e-mail address to send a text message to your phone.  (Remember that your e-mail server is down ;~) )
#
#  I recommend that a field be added to the GUI for people to set addresses for each domain.
#  The $from address and $curDir location should be pulled out of the database but I am too lazy. ;~)
#
# Thanks, Thomas Nelson (Forum name uncltom)

use Mail::Sendmail;

# E-mail info
my $to = '5098686189@txt.att.net';
my $from = 'mailcleaner@wearethenelsons.com';
my $subject = 'E-mail issue';
# Monitored directory
my $curDir = '/var/mailcleaner/spool/exim_stage4/input';
my $progname = 'txtalert.pl';
my $count = 0;

# Check to see if another thread is waiting for mail to resume

my $pid = `ps -C $progname -o pid=`;
print "Running PIDS:\n $pid \n\n";

if ((length $pid) > 7){
    die "Another thread is already running";
}

# Start checking the delivery queue
opendir(my $dh, $curDir) or die "opendir($curdir): $!";
while (my $de = readdir($dh)) {
  next if $de =~ /^\./ or $de =~ /config_file/;
  $count++;
}
closedir($dh);

print "$count files in the queue\n\n";

if ($count > 5){
   %mail = ( To => $to,
             From       => $from,
             Subject => $subject,
             Message => 'E-mail is not being delivered correctly.');
   sendmail(%mail) or die $Mail::Sendmail::error;
   print "OK.  Log says:\n", $Mail::Sendmail::log;
}
else {
   #mail flow appears to be ok
   die 'Email flowing properly';
}

#loop until the file count is 2 or less.

while ($count > 2)
{
   sleep (10);
   $count = 0;
   opendir(my $dh, $curDir) or die "opendir($curdir): $!";
   while (my $de = readdir($dh)) {
     next if $de =~ /^\./ or $de =~ /config_file/;
     $count++;
   }
   closedir($dh);
   print "$count files in the queue\n\n";
}
%mail = ( To    => $to,
          From  => $from,
          Subject => $subject,
          Message => 'E-mail delivery has been restored.');
sendmail(%mail) or die $Mail::Sendmail::error;
print "OK.  Log says:\n", $Mail::Sendmail::log;
print "\n\n";


