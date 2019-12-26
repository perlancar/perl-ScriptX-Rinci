package ScriptX::Rinci::CLI::Debug::DumpStashAfterGetArgs;

# AUTHORITY
# DATE
# DIST
# VERSION

# IFUNBUILT
use strict;
use warnings;
# END IFUNBUILT
use Log::ger;

use parent 'ScriptX::Base';

sub meta {
    return {
        summary => 'Dump stash after get_args event',
        conf => {
        },
    };
}

sub after_get_args {
    my ($self, $stash) = @_;

    require Data::Dump::Color;
    Data::Dump::Color::dd($stash);
    [200];
}

1;
# ABSTRACT:

=for Pod::Coverage ^(.+)$

=head1 SYNOPSIS

 use ScriptX 'Rinci::CLI::Debug::DumpStashAfterGetArgs';

If you want to exit afterwards:

 use ScriptX 'Rinci::CLI::Debug::DumpStashAfterGetArgs',
     Exit => {after => 'after_get_args'};


=head1 DESCRIPTION
