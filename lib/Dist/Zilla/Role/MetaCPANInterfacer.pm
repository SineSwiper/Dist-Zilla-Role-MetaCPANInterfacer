package Dist::Zilla::Role::MetaCPANInterfacer;

our $VERSION = '0.9'; # VERSION
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



=pod

=encoding utf-8

=head1 NAME

Dist::Zilla::Role::MetaCPANInterfacer - something that will interact with MetaCPAN's API

=head1 SYNOPSIS

    # in your plugin/etc. code
    with 'Dist::Zilla::Role::MetaCPANInterfacer';
 
    my $obj = $self->mcpan->fetch(...);

=head1 DESCRIPTION

This role is simply gives you a LE<lt>MetaCPAN::APIE<gt> object to use with caching, so
that other plugins can share that cache.  It uses the awesome example provided in
the LE<lt>MetaCPAN::APIE<sol>SYNOPSISE<gt>, contributed by Kent Fredric.

=head1 ATTRIBUTES

=head2 mcpan

Reader: mcpan

Writer: mcpan

Type: Object

Additional documentation: This is your L<MetaCPAN::API> object.  By default, it will lazily create the object, using C<mcpan_ua>
as the Tiny user agent.

=head2 mcpan_ua

Reader: mcpan_ua

Writer: mcpan_ua

Type: Object

Additional documentation: This is your L<HTTP::Tiny> compatible user agent.  By default, it will lazily create a L<HTTP::Tiny::Mech>
object, using C<mcpan_mechua> as the Mechanized user agent.

=head2 mcpan_cache

Reader: mcpan_cache

Writer: mcpan_cache

Type: Object

Additional documentation: This is your caching object.  By default, it will lazily create a L<CHI> object, using a File driver pointing
to C<~/.dzil/.webcache>.

=head2 mcpan_mechua

Reader: mcpan_mechua

Writer: mcpan_mechua

Type: Object

Additional documentation: This is your L<WWW::Mechanize> compatible user agent.  By default, it will lazily create a L<WWW::Mechanize::Cached::GZip>
object, using C<mcpan_cache> as the cache attribute.

=head1 METHODS

=head2 mcpan

Method originates in Dist::Zilla::Role::MetaCPANInterfacer.

=head2 mcpan_ua

Method originates in Dist::Zilla::Role::MetaCPANInterfacer.

=head2 mcpan_cache

Method originates in Dist::Zilla::Role::MetaCPANInterfacer.

=head2 mcpan_mechua

Method originates in Dist::Zilla::Role::MetaCPANInterfacer.

=head1 TODO

The caching stuff could potentially be split, but frankly, none of the existing 
plugins really need caching all that much.  I've at least called the CE<lt>.webcacheE<gt>
directory a generic name, so feel free to re-use it.

(Honestly, the only reason why this is a DZ module BE<lt>ISE<gt> the caching directory
name...)

=head1 SEE ALSO

LE<lt>Dist::Zilla::PluginBundle::PrereqsE<gt>, which uses this quite a bit.

=head1 AVAILABILITY

The project homepage is L<https://github.com/SineSwiper/Dist-Zilla-Role-MetaCPANInterfacer/wiki>.

The latest version of this module is available from the Comprehensive Perl
Archive Network (CPAN). Visit L<http://www.perl.com/CPAN/> to find a CPAN
site near you, or see L<https://metacpan.org/module/Dist::Zilla::Role::MetaCPANInterfacer/>.

=for :stopwords cpan testmatrix url annocpan anno bugtracker rt cpants kwalitee diff irc mailto metadata placeholders metacpan

=head1 SUPPORT

=head2 Internet Relay Chat

You can get live help by using IRC ( Internet Relay Chat ). If you don't know what IRC is,
please read this excellent guide: L<http://en.wikipedia.org/wiki/Internet_Relay_Chat>. Please
be courteous and patient when talking to us, as we might be busy or sleeping! You can join
those networks/channels and get help:

=over 4

=item *

irc.perl.org

You can connect to the server at 'irc.perl.org' and join this channel: #distzilla then talk to this person for help: SineSwiper.

=back

=head2 Bugs / Feature Requests

Please report any bugs or feature requests via L<L<https://github.com/SineSwiper/Dist-Zilla-Role-MetaCPANInterfacer/issues>|GitHub>.

=head1 AUTHOR

Brendan Byrd <BBYRD@CPAN.org>

=head1 COPYRIGHT AND LICENSE

This software is Copyright (c) 2012 by Brendan Byrd.

This is free software, licensed under:

  The Artistic License 2.0 (GPL Compatible)

=cut


__END__

