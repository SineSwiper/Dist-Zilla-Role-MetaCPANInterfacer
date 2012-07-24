package Dummy::Test;

use sanity;
use Moose;

with 'Dist::Zilla::Role::MetaCPANInterfacer';

sub tester {
   my $self = shift;
   my $mcpan = $self->mcpan;
}

package main;

use Test::Most tests => 1;

lives_ok(sub { Dummy::Test->tester(); }, 'MetaCPAN interface is up');