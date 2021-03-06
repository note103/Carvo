package Responder;
use strict;
use warnings;
use feature 'say';

use List::Util 'shuffle';
use List::MoreUtils 'uniq';

my $attr;
my $data;
my $key;
my $clean;
my $answer;
my $correct_component_buff;
my $giveup = '[Give up!]';

sub respond {
    my ($qa_switch, $attr, $data) = @_;

    $key = $data->{words}->[$attr->{num} - 1];
    $key =~ s/(.+)(\n)*$/$1/;

    my $question = $key;

    if ($qa_switch eq 'q') {
        my $limit = scalar(@{$data->{words}});
        my @select = (1..$limit);

        my $options;

        my $correct = $data->{dict}->{$key};
        $attr->{ans} = $correct;

        my %optmaker;
        $optmaker{$correct} = 1;

        my $opt_count = 5;
        $opt_count = scalar @select if (scalar @select < 5);

        my $rand;
        my $option;
        while (scalar(keys %optmaker) < $opt_count) {
            $rand = shuffle (@select);

            $option = $data->{dict}->{$data->{words}->[$attr->{num} - $rand]};
            next unless $option;

            $optmaker{$option} = 1;
        }

        my @options = keys %optmaker;
        @options = shuffle @options;

        push @options, $giveup;
        @options = map {$_ = "- $_"} @options;
        $options = join "\n", @options;

        say $question;

        $answer = qx(echo "$options" | cho | tr -d "\n");
        use Encode;
        $answer =~ s/\A- //;
        $answer = decode('utf8', $answer);
        say $answer;

        calculate($attr, $data);
    }
    elsif ($qa_switch eq 'a') {
        print $question = "$key($attr->{num}): $data->{dict}->{$key}\n";
        push @{ $data->{log} }, $question if ($attr->{add_correct_list} == 1);

        $clean = Util::cleanup($key);
        print `say -v $attr->{voice} $clean` if $attr->{voice_flag} == 1;
    }

    return $data->{log};
}

sub calculate {
    ($attr, $data) = @_;

    if ($answer eq $attr->{ans}) {
        $attr->{add_correct_list} = 1;
        $attr->{point}++;
        $attr->{total} = $attr->{point} + $attr->{miss};
        print "\nGood!!\n";
        $attr->{ng} = 0;

        if ($attr->{sound_flag} == 1) {
            if (( $attr->{point} % 10 ) == 0) {
                print `afplay $attr->{sound_dir}/ok10.mp3`;
            } elsif (( $attr->{point} % 25 ) == 0) {
                print `afplay $attr->{sound_dir}/ok25.mp3`;
            }
        }

        $data->{log} = respond('a', $attr, $data);
        print $data->{result} = result($attr, $data);
    }
    elsif ($answer eq $giveup) {
        $attr->{add_correct_list} = 0;
        $attr->{miss}++;
        $attr->{total} = $attr->{point} + $attr->{miss};
        push @{ $data->{log} }, "*$key: $data->{dict}->{$key}\n";
        push @{ $data->{fail} }, $key . "\n";
        print "\n";
        respond('a', $attr, $data);
        print $data->{result} = result($attr, $data);
    }
    else {
        $attr->{add_correct_list} = 0;
        $attr->{miss}++;
        $attr->{total} = $attr->{point} + $attr->{miss};

        push @{ $data->{log} }, "*$key: $data->{dict}->{$key}\n";
        push @{ $data->{fail} }, $key . "\n";

        say "\nNG! Again!\n";
        $attr->{ng} = 1;

        if ($attr->{sound_flag} == 1) {
            print `afplay $attr->{sound_dir}/ng.mp3`;
        }
        respond('q', $attr, $data);
    }

    return ($attr, $data);
}

sub result {
    my ($attr, $data) = @_;

    $data->{result}
        = "\nYou tried $attr->{total} times. $attr->{point} hits and $attr->{miss} errors.\n";

    return $data->{result};
}


1;
