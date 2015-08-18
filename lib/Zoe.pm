package Zoe;
use strict;
use warnings;
use Zoe::Kernel;
use Zoe::Session;
use constant {
    KERNEL  => 0,
    SESSION => 1,
    HEAP    => 2,
};

our $KERNEL ||= Zoe::Kernel->new;

sub import {
    my $package = caller();
    no strict 'refs'; ## no critic
    *{ $package . '::KERNEL'  } = \&KERNEL;
    *{ $package . '::SESSION' } = \&SESSION;
    *{ $package . '::HEAP'    } = \&HEAP;
}

sub run { $KERNEL->run }

1;
