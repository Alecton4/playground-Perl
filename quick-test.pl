#!/usr/bin/env perl
use 5.016;
use warnings;
use autodie;

use Test::More;

# the package fun is just here
package Foo;
use Scalar::Util qw(looks_like_number);
sub new { bless {}, shift }

# here we have an iterator, that returns n+1 each time it is called.
sub iterate : lvalue {
    my $self = shift;

    # here we ensure iterate exists
    $self->{iterate} = 0 unless defined $self->{iterate};

    if ( looks_like_number( $self->{iterate} ) ) {
        $self->{iterate}++;
    }
    else {
        $self->{iterate} = 0;
    }

    $self->{iterate};
}

package main;

my $i = Foo->new();
$i->iterate = 4;
while (1) {    # can't put the assignment in here
               # if starting w/ negative numbers.
               # I learned the hard way. B)
    my $ii = $i->iterate;
    say $ii;
    last if $ii >= 20;
}

__END__
