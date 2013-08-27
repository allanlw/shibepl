#!/usr/bin/perl
use strict;
use warnings;

# for ceil
use POSIX;

#for shuffle
use List::Util qw(shuffle reduce);

# colors list
#  0 == white
#  4 == light red
#  8 == yellow
#  9 == light green
# 11 == light cyan
# 12 == light blue
# 13 == light magenta
my @colors = ('4', '8', '9', '11', '12', '13');

#Usage: /shibe words, or messages separated, by,commas
sub cmd_shibe {
  my ($data, $server, $witem) = @_;

  my @words = ();

  my @mycolor = ();

  if (!$server || !$server->{connected}) {
    Irssi::print("Not connected to server");
    return;
  }

  if (!$data) {
    Irssi::print("No params specified");
    return;
  }

  if (!($witem && ($witem->{type} eq "CHANNEL" ||
                   $witem->{type} eq "QUERY"))) {
    Irssi::print("No active channel/user!");
    return;
  }

  push(@words, split(/,/, $data));

  # Add 1 "wow" for every three words or so
  for my $i (0 .. ceil($#words / 3.0)) {
    push(@words, "wow");
  }

  #trim all elements in the array
  for (@words) {
    s/\s+$//;
    s/^\s+//;
  }

  if ($words[0] eq "-r") {
    @mycolor = @colors;
    splice(@words, 0, 1);
  } else {
    push(@mycolor, 4); # light red
  }

  my @shuffled = shuffle @words;

  my $longest = reduce{ length($a) > length($b) ? $a : $b } @shuffled;

  my $rmax = 40 - length($longest);
  
  my @paddings = ();

  for my $i (0 .. $#shuffled) {
    push(@paddings, int(1.0 * $rmax / $#shuffled * $i));
  }

  my @shuffled_paddings = shuffle @paddings;

#  Irssi::print("rmax: ". $rmax . " shuffled: ".$#shuffled . " words: ".$#words);

  for (@shuffled) {
#    Irssi::print("printing: ".$_);
    my $newstr = "";
    $newstr .= $witem->{name} . " ";
    $newstr .= " "x pop(@shuffled_paddings);
    $newstr .= "\003" . sprintf("%02d", $mycolor[rand @mycolor]);
    $newstr .= $_;
    $witem->command("MSG ".$newstr);
  }
}

Irssi::command_bind('shibe', 'cmd_shibe');
