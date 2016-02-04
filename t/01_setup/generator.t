use 5.012;
use strict;
use Test::More 0.98;
use lib '../lib';
use Carvo;
use Setup::Generator;
use Carp;

my ($card_head, $card_filename, $card, $card_name, $card_dir);
my ($dict,         $fmt,           $file, $lesson);
my ($got_dict,     $got_fmt,       $got_card_name);
my $expect_dict;

subtest "yml" => sub {
    use YAML;

    # sample
    $lesson       = 'e';
    $fmt          = 'yml';
    $card_head = 'fs';
    $card_dir     = 'src/lesson/e_word';
    $card_name    = 'fast-and-slow';

    # got
    ($got_dict, $got_fmt, $got_card_name)
        = Generator::switch($lesson, $fmt, $card_head, $card_dir, $card_name);

    is $got_fmt,       $fmt,       'fmt_yml';
    is $got_card_name, $card_name, 'card_name_yml';

    $dict = "$card_dir/" . 'dict.yml';
    my $tmp_dict = YAML::LoadFile($dict);

    $card = "$card_dir/".$card_head.'_'."$card_name.txt";

    open my $fh, '<', $card or croak("Can't open card file.");
    my %set_dict;
    for (<$fh>) {
        chomp;
        $set_dict{$_} = $tmp_dict->{$_};
    }
    $expect_dict = \%set_dict;
    close $fh;

    diag 'got: ' . $got_dict->{absurdly};
    diag 'expect: ' . $expect_dict->{absurdly};
    is $got_dict->{absurdly}, $expect_dict->{absurdly}, 'dict_yml';
};


subtest "json" => sub {
    use Encode;
    use JSON;
    use open qw/:utf8 :std/;

    # sample
    $lesson       = 'p';
    $fmt          = 'json';
    $card_head = 't';
    $card_dir     = 'src/lesson/p_speech';
    $card_name    = 'timcook';

    # got
    ($got_dict, $got_fmt, $got_card_name)
        = Generator::switch($lesson, $fmt, $card_head, $card_dir, $card_name);

    is $got_fmt,       $fmt,       'fmt_json';
    is $got_card_name, $card_name, 'card_name_json';

    $dict = "$card_dir/" . 'dict.json';
    open my $fh, '<', $dict or croak("Can't open JSON dict file.");
    my $json = do { local $/; <$fh> };
    my $tmp_dict = decode_json(encode('utf8', $json));
    close $fh;

    $card = "$card_dir/".$card_head.'_'."$card_name.txt";
    open $fh, '<', $card or croak("Can't open JSON card file.");
    my %set_dict;
    for (<$fh>) {
        chomp;
        $set_dict{$_} = $tmp_dict->{$_};
    }
    $expect_dict = \%set_dict;
    close $fh;

    diag 'got: ' . $got_dict->{'01'};
    diag 'expect: ' . $expect_dict->{'01'};
    is $got_dict->{'01'}, $expect_dict->{'01'}, 'dict_json';
};

done_testing;
