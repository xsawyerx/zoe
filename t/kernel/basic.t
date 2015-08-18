use strict;
use warnings;
use Test::More;
BEGIN { use_ok('Zoe') }

my $kernel = $Zoe::KERNEL;
isa_ok( $kernel, 'Zoe::Kernel' );
can_ok( $kernel, 'run' );
is( $kernel->run, 1, 'run() finished' );

is( KERNEL,  0, 'KERNEL is the first item' );
is( SESSION, 1, 'SESSION is the first item' );
is( HEAP,    2, 'HEAP is the first item' );

done_testing;
