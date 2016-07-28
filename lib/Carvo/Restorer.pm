package Restorer {
    use strict;
    use warnings;
    use feature 'say';

    use open ':utf8';
    binmode STDOUT, ':utf8';
    use Encode;
    use YAML;

    use Carp 'croak';
    use Time::Piece;
    use File::Slurp qw/read_dir read_file/;
    use File::Path qw/mkpath rmtree/;

    my $dir_name = 'src/save';

    sub save {
        my ($attr, $data) = @_;
        my ($file_num, $file_words, $file_dict, $file_cardname, $file_fail);

        my $datetime = localtime->datetime(T => '-');
        $datetime =~ s/(\d{4}-\d{2}-\d{2}-\d{2}):(\d{2}):(\d{2})/$1-$2-$3/;

        my $save_path = "$dir_name/$datetime";

        mkpath($save_path);

        $file_num = "$save_path/num.txt";
        open my $fh_print_num, '>', $file_num or croak("Can't open saving num file: $!");
        print $fh_print_num $attr->{num};
        close $fh_print_num;

        $file_words = "$save_path/words.txt";
        open my $fh_print_words, '>', $file_words
            or croak("Can't open saving words file: $!");
        my @tidy;
        for (@{ $data->{words} }) { push @tidy, $_ . "\n"; }
        for (@tidy)               { $_ =~ s/\n\n/\n/; }
        for (@tidy)               { print $fh_print_words $_; }
        close $fh_print_words;

        $file_fail = "$save_path/fail.txt";
        open my $fh_print_fail, '>', $file_fail
            or croak("Can't open saving fail file: $!");
        my @tidy_fail;
        for (@{ $data->{fail} }) { push @tidy_fail, $_ . "\n"; }
        for (@tidy_fail)         { $_ =~ s/\n\n/\n/; }
        for (@tidy_fail)         { print $fh_print_fail $_; }
        close $fh_print_fail;

        $file_dict = "$save_path/save.txt";
        open my $fh_print_dict, '>', $file_dict
            or croak("Can't open saving dict file: $!");
        my $yaml = YAML::Dump($data->{dict});
        print $fh_print_dict $yaml;

        $file_cardname = "$save_path/cardname.txt";
        open my $fh_print_cardname, '>', $file_cardname
            or croak("Can't open saving cardname file: $!");
        print $fh_print_cardname $attr->{card_name};
        close $fh_print_cardname;
        close $fh_print_dict;

        return ($attr, $data);
    }

    sub read_only {
        my $save;
        my @dirh = read_dir($dir_name);
        for my $saved_datetime (@dirh) {
            if ($saved_datetime =~ /(\d[\d-]+\d)$/) {
                $saved_datetime = $1;
                my $save_path = $dir_name . '/' . $saved_datetime;

                my ($file_num, $file_words, $file_cardname);
                my ($read_num, $read_cardname, $read_limit);

                $file_num = "$save_path/num.txt";
                $read_num = read_file($file_num);

                $file_words = "$save_path/words.txt";
                my $fh_read_words = read_file($file_words);

                my @words = split /\n/, $fh_read_words;
                $read_limit = @words;

                $file_cardname = "$save_path/cardname.txt";
                $read_cardname = read_file($file_cardname);

                push @{ $save->{saved_info} },
                    $saved_datetime . " -> $read_cardname: $read_num/$read_limit";
                push @{ $save->{saved_datetime} }, $saved_datetime;
                push @{ $save->{$saved_datetime}->{card_name} }, $read_cardname;
                push @{ $save->{$saved_datetime}->{num} },       $read_num;
                push @{ $save->{$saved_datetime}->{limit} },     $read_limit;
            }
        }
        return $save;
    }

    sub restore_func {
        my ($attr, $data) = @_;

        my $save = read_only();
        my @saved_datetime = @{ $save->{saved_datetime} };
        if ($attr->{selected_restore} eq '[Cancel]') {
            say "Canceled.\n";
            return ($attr, $data, 'off');
        }
        my $matched_dir;
        if ($attr->{selected_restore} =~ /\A(\S+)/) {
            $matched_dir = $1;
        }
        my $save_path = $dir_name . '/' . $matched_dir;
        if ($attr->{command_restore} eq 'restore') {
            my ($file_num, $file_words, $file_cardname, $file_fail);

            $file_num = "$save_path/num.txt";
            open my $fh_read_num, '<', $file_num
                or croak("Can't open saved num file for revert: $!");
            $attr->{num} = <$fh_read_num>;
            close $fh_read_num;

            $file_words = "$save_path/words.txt";
            open my $fh_read_words, '<', $file_words
                or croak("Can't open saved words file for revert: $!");
            my @words = <$fh_read_words>;
            close $fh_read_words;

            $attr->{limit} = @words;

            for (@words) { chomp; $_ =~ s/^\n//; }
            $data->{words} = \@words;

            $file_fail = "$save_path/fail.txt";
            open my $fh_read_fail, '<', $file_fail
                or croak("Can't open saved fail file for revert: $!");
            my @fail = <$fh_read_fail>;
            close $fh_read_fail;

            for (@fail) { chomp; $_ =~ s/^\n//; }
            $data->{fail} = \@fail;

            my $file_dict = "$save_path/save.txt";
            open my $fh_read_dict, '<', $file_dict
                or croak("Can't open saved dict file for revert: $!");
            $data->{dict} = do { local $/; <$fh_read_dict> };
            $data->{dict} = YAML::Load($data->{dict});
            close $fh_read_dict;
        }
        elsif ($attr->{command_restore} eq 'remove') {
            rmtree($save_path);
            say "Delete \"$matched_dir -> $save->{$matched_dir}->{card_name}[0]: $save->{$matched_dir}->{num}[0]/$save->{$matched_dir}->{limit}[0]\" successful.\n";
        }
        return ($attr, $data, 'on');
    }
}

1;
