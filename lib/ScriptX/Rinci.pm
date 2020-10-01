package ScriptX::Rinci;

# AUTHORITY
# DATE
# DIST
# VERSION

use strict 'subs', 'vars';
use parent 'ScriptX_Base';
require ScriptX;

sub meta {
    +{
        summary => 'Run Rinci function',
    };
}

sub new {
    my ($class, %args) = (shift, @_);
    $args{func} or die "Please specify func";
    $args{func} =~ /\A\w+(::\w+)+\z/ or die "Invalid syntax for func, please use PACKAGE::FUNCNAME";
    $class->SUPER::new(%args);
}

sub on_run {
    my ($self, $stash) = @_;

    my $func = $self->{func};
    my ($pkg, $uqfunc) = $func =~ /(.+)::(.+)/;
    $pkg ||= "main";
    $uqfunc ||= $func;

    (my $pkg_pm = "$pkg.pm") =~ s!::!/!g;
    require $pkg_pm;

    my $meta = ${"$pkg\::SPEC"}{$uqfunc}
        or die "There is no Rinci metadata for $func";

    # we should just supply a handler for get_args and not define it
    ScriptX::run_event(
        name => 'get_args',
        on_success => sub {
            require Perinci::Sub::GetArgs::Argv;

            my $stash = shift;

            $stash->{args} //= {};

            my $res = Perinci::Sub::GetArgs::Argv::get_args_from_argv(
                args => $stash->{args},
                argv => \@ARGV,
                meta => $meta,
            );
            die "Cannot get arguments: $res->[0] - $res->[1]" unless $res->[0] == 200;
            [200];
        },
    );

    # XXX check args_as
    my $res = &{$func}(%{ $stash->{args} });

    $res = [200, "OK", $res] if $meta->{result_naked};

    require Perinci::Result::Format::Lite;

    print Perinci::Result::Format::Lite::format($res, 'text');

    $res;
}

1;
# ABSTRACT:

=head1 SYNOPSIS

 use ScriptX 'Rinci' => {
     func => 'PACKAGENAME::FUNCNAME',
 };


=head1 DESCRIPTION

B<EARLY, EXPERIMENTAL RELEASE. MOST THINGS ARE NOT IMPLEMENTED YET.>

The goal of this plugin (and other related plugins) is to replace
L<Perinci::CmdLine> (this includes L<Perinci::CmdLine::Classic> and
L<Perinci::CmdLine::Lite>) with a more modular and flexible framework.
