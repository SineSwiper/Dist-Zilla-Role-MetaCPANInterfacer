package Dummy::Test;

our $VERSION = v1.2.3;

use sanity;
use Moose;

with 'Dist::Zilla::Role::MetaCPANInterfacer';

sub tester {
   my $self = shift;
   my $mcpan = $self->mcpan;
}

package main;

use Test::Most tests => 6;

my $t;
lives_ok(sub {
   $t = Dummy::Test->new();
   $t->tester();
}, 'MetaCPAN interface is up');

can_ok(
   $t,
   qw/
      mcpan
      mcpan_ua
      mcpan_mechua
      mcpan_cache
   /
);

isa_ok( $t->mcpan,'MetaCPAN::API' );
isa_ok( $t->mcpan_ua,'HTTP::Tiny::Mech' );
isa_ok( $t->mcpan_mechua,'WWW::Mechanize::Cached::GZIP' );
isa_ok( $t->mcpan_cache,'CHI' );

diag $t->mcpan_mechua->agent;
