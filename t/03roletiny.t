## skip Test::Tabs
use strict;
use warnings;
use Test::More;

my $constructor = sub
{
	my $class = shift;
	bless { @_==1 ? %{+shift} : @_ }, $class;
};

{ package Trait;
  use Role::Tiny;
  sub foo { shift->{foo} }

  package Class;
  use Role::Tiny::With;
  *new = $constructor;
  with 'MooX::Traits';

  package Another::Trait;
  use Role::Tiny;
  sub bar { shift->{bar} }

  package Another::Class;
  use Role::Tiny::With;
  *new = $constructor;
  with 'MooX::Traits';
  sub _trait_namespace { 'Another' }
}

foreach my $trait ( 'Trait', ['Trait' ] ) {
    my $instance = Class->new_with_traits( traits => $trait, foo => 'hello' );
    isa_ok $instance, 'Class';
    can_ok $instance, 'foo';
    is $instance->foo, 'hello';
}

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
