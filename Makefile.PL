
use strict;
use warnings;

use 5.010001;

use ExtUtils::MakeMaker 6.30;



my %WriteMakefileArgs = (
  "ABSTRACT" => "something that will interact with MetaCPAN's API",
  "AUTHOR" => "Brendan Byrd <BBYRD\@CPAN.org>",
  "BUILD_REQUIRES" => {
    "Moose" => "0.34",
    "Test::CheckDeps" => "0.002",
    "Test::Most" => "0.01",
    "Test::UseAllModules" => "0.10"
  },
  "CONFIGURE_REQUIRES" => {},
  "DISTNAME" => "Dist-Zilla-Role-MetaCPANInterfacer",
  "EXE_FILES" => [],
  "LICENSE" => "artistic_2",
  "NAME" => "Dist::Zilla::Role::MetaCPANInterfacer",
  "PREREQ_PM" => {
    "CHI" => "0.01",
    "File::HomeDir" => 0,
    "HTTP::Tiny::Mech" => "v0.1.0",
    "List::AllUtils" => "0.01",
    "MetaCPAN::API" => "0.02",
    "Moose::Role" => "0.07",
    "Path::Class" => "0.17",
    "WWW::Mechanize::Cached::GZip" => "0.10",
    "namespace::clean" => "0.06",
    "sanity" => "0.91"
  },
  "VERSION" => "0.95",
  "test" => {
    "TESTS" => "t/*.t"
  }
);


unless ( eval { ExtUtils::MakeMaker->VERSION(6.56) } ) {
  my $br = delete $WriteMakefileArgs{BUILD_REQUIRES};
  my $pp = $WriteMakefileArgs{PREREQ_PM};
  for my $mod ( keys %$br ) {
    if ( exists $pp->{$mod} ) {
      $pp->{$mod} = $br->{$mod} if $br->{$mod} > $pp->{$mod};
    }
    else {
      $pp->{$mod} = $br->{$mod};
    }
  }
}

delete $WriteMakefileArgs{CONFIGURE_REQUIRES}
  unless eval { ExtUtils::MakeMaker->VERSION(6.52) };

WriteMakefile(%WriteMakefileArgs);



