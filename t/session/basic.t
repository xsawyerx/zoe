use strict;
use warnings;
use Test::More;
BEGIN { use_ok('Zoe') }

is( KERNEL,  0, 'KERNEL is the first item' );
is( SESSION, 1, 'SESSION is the second item' );
is( HEAP,    2, 'HEAP is the third item' );

my $global_heap = { foo => 'bar' };

my $session = Zoe::Session->create(
    events  => {
        _start => \&start,
        _stop  => \&stop,
        ping   => \&ping_event,
    },

    # session options
    options => { debug => 1 },

    heap    => $global_heap,
);

my @events;
sub start {
    my ( $kernel, $session, $heap ) = @_[ KERNEL, SESSION, HEAP ];
    push @events, '_start';

    isa_ok( $kernel, 'Zoe::Kernel' );
    is( $kernel, $Zoe::KERNEL, 'Same kernel as global' );
    isa_ok( $session, 'Zoe::Session' );
    is_deeply( $heap, $global_heap, 'Same heap' );

    $kernel->yield( $session->ID, 'ping' );
}

sub ping_event {
    push @events, 'ping';

    ++$_[HEAP]->{'count'} >= 3
        or $_[SESSION]->yield('ping');
}

sub stop {
    push @events, '_stop';
}

ok( Zoe->run, 'Zoe finished successfully' );

is_deeply(
    \@events,
    [
        '_start',
        'ping', 'ping', 'ping',
        '_stop',
    ],
    'All events run',
);

is_deeply(
    $global_heap,
    {
        foo   => 'bar',
        count => 3,
    },
    'Heap filled up properly',
);

done_testing;
