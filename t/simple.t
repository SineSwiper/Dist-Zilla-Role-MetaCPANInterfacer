package Dummy::Test;

use sanity;
use Moose;
use Test::Most tests => 1;

with 'Dist::Zilla::Role::MetaCPANInterfacer';

sub tester {
   my $self = shift;
   my $mcpan = $self->mcpan;
}

lives_ok { Dummy::Test->tester() } 'MetaCPAN interface is up';
