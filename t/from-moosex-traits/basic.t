## skip Test::Tabs
use strict;
use warnings;
use Test::Requires { 'Test::Fatal' => '0' };
use Test::Requires { 'Moo' => '1.000000' };
use Test::More;
use Test::Fatal;

{ package Trait;
  use Moo::Role;
  has 'foo' => (
      is       => 'ro',
      isa      => sub { defined($_[0]) && !ref($_[0]) or die },
      required => 1,
  );

  package Class;
  use Moo;
  with 'MooX::Traits';

  package Another::Trait;
  use Moo::Role;
  has 'bar' => (
      is       => 'ro',
      isa      => sub { defined($_[0]) && !ref($_[0]) or die },
      required => 1,
  );

  package Another::Class;
  use Moo;
  with 'MooX::Traits';
  sub _trait_namespace { 'Another' }

}

foreach my $trait ( 'Trait', ['Trait' ] ) {
    my $instance = Class->new_with_traits( traits => $trait, foo => 'hello' );
    isa_ok $instance, 'Class';
    can_ok $instance, 'foo';
    is $instance->foo, 'hello';
}

like
    exception { Class->with_traits('Trait')->new; },
    qr/required/,
    'foo is required';

{
    my $instance = Class->with_traits->new;
    isa_ok $instance, 'Class';
    ok !$instance->can('foo'), 'this one cannot foo';
}
{
    my $instance = Class->with_traits()->new;
    isa_ok $instance, 'Class';
    ok !$instance->can('foo'), 'this one cannot foo either';
}
{
    my $instance = Another::Class->with_traits( 'Trait' )->new( bar => 'bar' );
    isa_ok $instance, 'Another::Class';
    can_ok $instance, 'bar';
    is $instance->bar, 'bar';
}
# try hashref form
{
    my $instance = Another::Class->with_traits('Trait')->new({ bar => 'bar' });
    isa_ok $instance, 'Another::Class';
    can_ok $instance, 'bar';
    is $instance->bar, 'bar';
}
{
    my $instance = Another::Class->with_traits('Trait', '+Trait')->new(
        foo => 'foo',
        bar => 'bar',
    );
    isa_ok $instance, 'Another::Class';
    can_ok $instance, 'foo';
    can_ok $instance, 'bar';
    is $instance->foo, 'foo';
    is $instance->bar, 'bar';
}

done_testing;
