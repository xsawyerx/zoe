package Zoe::Kernel;
use strict;
use warnings;
use constant {
    START => '_start',
    STOP  => '_stop',
};

use AnyEvent;

sub new {
    my ( $class, %opts ) = @_;
    return bless {%opts}, $class;
}

sub _sessions      { $_[0]->{'_sessions'}  ||= +{}    }
sub _kernel_cv     { $_[0]->{'_kernel_cv'} ||= AE::cv }
sub reset          { $_[0]->{'_kernel_cv'}   = AE::cv }
sub _kernel_cv_inc { $_[0]->_kernel_cv->begin         }
sub _kernel_cv_dec { $_[0]->_kernel_cv->end           }

sub add_session {
    my ( $self, $session, ) = @_;
    $self->_sessions->{ $session->ID } = $session;
    $self->yield( $session->ID, START(), $session->heap );
}

sub find_session {
    my ( $self, $session_id ) = @_;
    my $session = $self->_sessions->{$session_id}
        or warn "No such session ($session_id)\n" and return;

    return $session;
}

sub yield {
    my ( $self, $session_id, $event, @args ) = @_;
    my $session = $self->find_session($session_id)
        or return;

    $self->_kernel_cv_inc;
    AE::postpone {
        $session->events->{$event}->(
            $self, $session, $session->heap, @args
        );

        $self->_kernel_cv_dec;
    }
}

sub delay {
    my ( $self, $ID, $event, $time, @args ) = @_;
    return $self->_timer( $ID, $event, $time, 0, @args );
}

sub timer {
    my $self = shift;
    return $self->_timer(@_);
}

sub _timer {
    my ( $self, $session_id, $event, $time, $repeat, @args ) = @_;
    my $session = $self->find_session($session_id)
        or return;

    $self->_kernel_cv_inc;
    my $timer = AE::timer $time, $repeat, sub {
        $session->events->{$event}->(
            $self, $session, $session->heap, @args
        );

        $self->_kernel_cv_dec;
    };

    return $session->{'_timers'}{$timer} = $timer;
}

sub run {
    my $self     = shift;
    my $sessions = $self->_sessions;

    if ( %{$sessions} ) {
        # run all events
        $self->_kernel_cv->recv;

        # run all stop events
        $self->reset;

        my @IDs_with_stop = grep $sessions->{$_}->events->{ STOP() },
                            keys %{$sessions};

        $self->yield( $_, STOP(), $sessions->{$_}->heap )
            for @IDs_with_stop;

        @IDs_with_stop and $self->_kernel_cv->recv;
    }

    return 1;
}

1;
