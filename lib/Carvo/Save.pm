use strict;
use warnings;
use 5.012;

package Save {
    use JSON;
    use utf8;
    my ($num, $words, $english, $custom);
    sub save {
        ($num, $words, $english) = @_;
        open my $fh_out_num, '>', 'data/save/main/num.txt' or die $!;
        print $fh_out_num $num;
        close $fh_out_num;
        open my $fh_out_arr, '>', 'data/save/main/words.txt' or die $!;
        my @tidy;
        for (@$words) { push @tidy, $_."\n"; }
        for (@tidy) { $_ =~ s/\n\n/\n/; }
        for (@tidy) { print $fh_out_arr $_; }
        close $fh_out_arr;
        open my $fh_out_hash, '>', 'data/save/main/save.txt' or die $!;
        print $fh_out_hash encode_json($english)."\n";
        close $fh_out_hash;
    }
    sub buffer {
        ($num, $words, $english) = @_;
        open my $fh_out_num, '>', 'data/save/buffer/num.txt' or die $!;
        print $fh_out_num $num;
        close $fh_out_num;
        open my $fh_out_arr, '>', 'data/save/buffer/words.txt' or die $!;
        my @tidy;
        for (@$words) { push @tidy, $_."\n"; }
        for (@tidy) { $_ =~ s/\n\n/\n/; }
        for (@tidy) { print $fh_out_arr $_; }
        close $fh_out_arr;
        open my $fh_out_hash, '>', 'data/save/buffer/save.txt' or die $!;
        print $fh_out_hash encode_json($english)."\n";
        close $fh_out_hash;
    }
    sub revival {
        open my $fh_in_num, '<', 'data/save/main/num.txt' or die $!;
        $num = <$fh_in_num>;
        close $fh_in_num;
        open my $fh_in_arr, '<', 'data/save/main/words.txt' or die $!;
        my @words = <$fh_in_arr>;
        for (@words) { $_ =~ s/^\n//; }
        $words = \@words;
        close $fh_in_arr;
        open my $fh_in_hash, '<', 'data/save/main/save.txt' or die $!;
        my @tmp = <$fh_in_hash>;
        $english = decode_json("@tmp");
        close $fh_in_hash;
        return ($num, $words, $english);
    }
    sub unrev {
        open my $fh_in_num, '<', 'data/save/buffer/num.txt' or die $!;
        $num = <$fh_in_num>;
        close $fh_in_num;
        open my $fh_in_arr, '<', 'data/save/buffer/words.txt' or die $!;
        my @words = <$fh_in_arr>;
        for (@words) { $_ =~ s/^\n//; }
        $words = \@words;
        close $fh_in_arr;
        open my $fh_in_hash, '<', 'data/save/buffer/save.txt' or die $!;
        my @tmp = <$fh_in_hash>;
        $english = decode_json("@tmp");
        close $fh_in_hash;
        return ($num, $words, $english);
    }
}
1;

