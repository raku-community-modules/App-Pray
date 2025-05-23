unit module Pray::Input::JSON;
# forked from https://github.com/tadzik/JSON-Unmarshal
# will either be heavily customized for scene files, or replaced

use JSON::Fast:ver<0.19+>;

sub panic ($json, $type) {
    die "Cannot load $json.raku() to type $type.raku()"
}

multi _load ($json, Int) {
    $json ~~ Int
      ?? Int($json)
      !! panic($json, Int)
}

multi _load ($json, Numeric) {
    $json ~~ Numeric
      ?? Num($json)
      !! panic($json, Numeric)
}

multi _load ($json, Str) {
    $json ~~ Stringy
      ?? Str($json)
      !! Nil
}

multi _load ($json is copy, Any $x) {
    my $type = $x.WHAT;
    my %args;
    for $type.^attributes -> $attr {
        my $name = $attr.name.substr(2);
        next unless $json{$name} :exists;
        %args{$name} := _load($json{$name} :delete, $attr.type);
    }
    for $json.keys -> $arg {
        %args{$arg} := $json{$arg};
    }
    $type.new(|%args)
}

multi _load ($json, @x) {
    $json.list.map: { _load($_, @x.of) }
}

multi _load ($json, Mu) {
    $json
}

our sub load_file ($file, $obj) {
    load_json(slurp($file), $obj)
}

our sub load_json ($json, $obj) {
    load_data(from-json($json), $obj)
}

our sub load_data ($data, $obj) {
    _load($data, $obj)
}

# vim: expandtab shiftwidth=4
