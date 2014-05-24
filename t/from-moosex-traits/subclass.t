## skip Test::Tabs
use strict;
use warnings;
use Test::Requires { 'Test::Fatal' => '0' };
use Test::Requires { 'Moo' => '1.000000' };
use Test::More tests => 3;
use Test::Fatal;

{ package Foo;
  use Moo;
  with 'MooX::Traits';

  package Bar;
  use Moo;
  extends 'Foo';

  package Trait;
  use Moo::Role;

  sub foo { return 42 };
}

my $instance;
is
    exception {
        $instance = Bar->new_with_traits( traits => ['Trait'] );
    },
    undef,
    'creating instance works ok';

ok $instance->does('Trait'), 'instance does trait';
is $instance->foo, 42, 'trait works';
