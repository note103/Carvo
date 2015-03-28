#!/usr/bin/env perl
use strict;
use warnings;

my $s4 = '    ';
my $s8 = $s4.$s4;
my @line;
for my $str (<DATA>) {
    $str =~ s/"/\\"/g;
    if ($str =~ s/^$s4(.+): (.+)/$s8"$1" : "$2",/g) {
    } elsif ($str =~ s/^>$s4(.+): (.+)/$s8">$1" : "$2",/g) {
    } elsif ($str =~ s/^<$s4(.+): (.+)/$s8"<$1" : "$2",/g) {
    } elsif ($str =~ s/^(.+): (.+)/$s4"$1" : "$2",/g) {
    }
    push @line, $str;
}
for my $str2 (@line) {
    if ($str2 =~ /^($s4".+" : )(.+)/) {
        print  "$1\[\n$s8$2\n";
    } elsif ($str2 =~ /^($s8")>(.+" : ".+"),/) {
        print  "$s8\{\n$s4$1$2,\n";
    } elsif ($str2 =~ /^($s8")<(.+" : ".+"),/) {
        print  "$s4$1$2\n$s8\}\n$s4\],\n";
    } elsif ($str2 =~ /^($s8".+" : ".+"),/) {
        print  "$s4$1,\n";
    }
}
__DATA__