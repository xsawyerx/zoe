package Zoe::Session;
use strict;
use warnings;
use AnyEvent;

our $id = 0;

sub ID     { $_[0]->{'id'} }
sub heap   { $_[0]->{'heap'} }
sub events { $_[0]->{'events'} }

sub create {
    my ( $class, %opts ) = @_;

    my $self = bless {
        events  => $opts{'events'},
        options => $opts{'options'} || {},
        heap    => $opts{'heap'}    || {},
        id      => $opts{'ID'}      || $id++,
    }, $class;

    $Zoe::KERNEL->add_session($self);

    return $self;
}

sub yield {
    my ( $self, $event, @args ) = @_;
    $Zoe::KERNEL->yield( $self->ID, $event, @args );
}

sub delay {
    my ( $self, $event, $time, @args ) = @_;
    $Zoe::KERNEL->delay( $self->ID, $event, $time, @args );
}

sub timer {
    my ( $self, $event, $time, $repeat, @args ) = @_;
    return $Zoe::KERNEL->timer( $self->ID, $event, $time, $repeat, @args );
}

1;
