use strict;
use warnings;
use Test::More;
BEGIN { use_ok('Zoe') }

my ( @events, @times, $delay );
Zoe::Session->create(
    ID     => 'Thingie',
    events => {
        _start  => sub {
            push @events, '_start';
            $_[SESSION]->yield('next');
            $_[SESSION]->delay( delayed => 1 );
        },

        next    => sub {
            push @events, 'next';

            ++$_[HEAP]->{'count'} >= 3
                or $_[KERNEL]->yield( Thingie => 'next' );
        },

        delayed => sub { undef $_[HEAP]->{'timer'}; $delay++ },
    },
);

ok( Zoe->run, 'Zoe finished successfully' );

is_deeply(
    \@events,
    [ '_start', 'next', 'next', 'next' ],
    'All events run',
);

ok( $delay, 'Delayed action was called' );

done_testing;
