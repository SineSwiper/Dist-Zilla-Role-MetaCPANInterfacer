package Dist::Zilla::Role::MetaCPANInterfacer;

# VERSION
# ABSTRACT: something that will interact with MetaCPAN's API

use sanity;

use Moose;
use CHI;
use WWW::Mechanize::Cached;
use HTTP::Tiny::Mech;
use MetaCPAN::API;

use Path::Class;
use File::HomeDir;
use Scalar::Util qw{blessed};
use Acme::Indent qw(ai);  # no idea why this is Acme::

has mcpan => (
   is      => 'rw',
   isa     => 'Object',
   lazy    => 1,
   default => sub {
      MetaCPAN::API->new( ua => $_[0]->mcpan_ua );
   },
   documentation => ai('
      This is your L<MetaCPAN::API> object.  By default, it will lazily create the object, using C<mcpan_ua>
      as the Tiny user agent.
   '),
);

has mcpan_ua => (
   is      => 'rw',
   isa     => 'Object',
   lazy    => 1,
   default => sub {
      HTTP::Tiny::Mech->new( mechua => $_[0]->mcpan_mechua );
   },
   documentation => ai('
      This is your L<HTTP::Tiny> compatible user agent.  By default, it will lazily create a L<HTTP::Tiny::Mech>
      object, using C<mcpan_mechua> as the Mechanized user agent.
   '),
);

has mcpan_mechua => (
   is      => 'rw',
   isa     => 'Object',
   lazy    => 1,
   default => sub {
      $_[0]->_mcpan_set_agent_str(
         WWW::Mechanize::Cached::GZip->new( cache => $_[0]->mcpan_cache )
      );
   },
   documentation => ai('
      This is your L<WWW::Mechanize> compatible user agent.  By default, it will lazily create a L<WWW::Mechanize::Cached::GZip>
      object, using C<mcpan_cache> as the cache attribute.
   '),
);

has mcpan_cache => (
   is      => 'rw',
   isa     => 'Object',
   lazy    => 1,
   default => sub {
      CHI->new(
         namespace  => __PACKAGE__,
         driver     => 'File',
         expires_in => '1d',
         root_dir   => Path::Class::dir( File::HomeDir->my_home )->subdir('.dzil', '.webcache')->stringify,
      )
   },
   documentation => ai('
      This is your caching object.  By default, it will lazily create a L<CHI> object, using a File driver pointing
      to C<~/.dzil/.webcache>.
   '),
);

sub _mcpan_set_agent_str {
   my ($self, $ua) = @_;
   my $o = ucfirst($^O);
   my $os;
   
   if ($o eq 'MSWin32') {
      my @osver = Win32::GetOSVersion();
      $os = ($osver[0] || Win32::GetOSName()).' v'.join('.', @osver[1..3]);
   }
   else {
      $os = `/bin/uname -srmo`;  ### LAZY: Backticks
      $os =~ s/[\n\r]+|^\s+|\s+$//g;
   }
   
   my $v = eval '$'.blessed($self).'::VERSION';
   $ua->agent("Mozilla/5.0 ($o; $os) ".blessed($self)."/$v ".$ua->_agent);

   return $ua;
}

42;

__END__

=begin wikidoc

= SYNOPSIS
 
   # in your plugin/etc. code
   with 'Dist::Zilla::Role::MetaCPANInterfacer';
   
   my $obj = $self->mcpan->fetch(...);
 
= DESCRIPTION
 
This role is simply gives you a L<MetaCPAN::API> object to use with caching, so
that other plugins can share that cache.  It uses the awesome example provided in
the L<MetaCPAN::API/SYNOPSIS>, contributed by Kent Fredric.

= TODO

The caching stuff could potentially be split, but frankly, none of the existing 
plugins really need caching all that much.  I've at least called the C<.webcache>
directory a generic name, so feel free to re-use it.

(Honestly, the only reason why this is a DZ module B<IS> the caching directory
name...)

= SEE ALSO

L<Dist::Zilla::PluginBundle::Prereqs>, which uses this quite a bit.

=end wikidoc
