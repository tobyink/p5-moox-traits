use strict;
use warnings;
use Test::Requires { 'Test::Fatal' => '0' };
{ package AAA; use Test::Requires { 'Moo' => '1.000000' } };
{ package BBB; use Test::Requires { 'Package::Variant' => '0' } };
use Test::More;
use Test::Fatal;

plan tests => 11;

{
    package Role;
    use Moo::Role;

    has 'gorge' => (
        is       => 'ro',
        required => 1,
    );
}

{
    package PRole;
    use Package::Variant
        importing => ['Moo::Role'],
        subs      => [ qw(has around before after with) ];
    
    sub make_variant {
        my ($class, $target_package, %p) = @_;
        has $p{foo} => (
            is       => 'ro',
            required => 1,
        );
    }
}

{
    package Class;
    use Moo;

    with 'MooX::Traits';
}

is
    exception { Class->new; },
    undef,
    'making class is OK';

is
    exception { Class->new_with_traits; },
    undef,
    'making class with no traits is OK';

my $a;

is
    exception {
        $a = Class->new_with_traits(
            traits => ['PRole' => { foo => 'OHHAI' }],
            OHHAI  => 'I FIXED THAT FOR YOU',
        );
    },
    undef,
    'prole is applied OK';

isa_ok $a, 'Class';
is $a->OHHAI, 'I FIXED THAT FOR YOU', 'OHHAI accessor works';

is
    exception {
        undef $a;
        $a = Class->new_with_traits(
            traits => ['PRole' => { foo => 'OHHAI' }, 'Role'],
            OHHAI  => 'I FIXED THAT FOR YOU',
            gorge  => 'three rivers',
        );
    },
    undef,
    'prole is applied OK along with a normal role';

can_ok $a, 'OHHAI', 'gorge';

is
    exception {
        undef $a;
        $a = Class->new_with_traits(
            traits => ['Role', 'PRole' => { foo => 'OHHAI' }],
            OHHAI  => 'I FIXED THAT FOR YOU',
            gorge  => 'columbia river',
        );
    },
    undef,
    'prole is applied OK along with a normal role (2)';

can_ok $a, 'OHHAI', 'gorge';

is
    exception {
        undef $a;
        $a = Class->new_with_traits(
            traits => ['Role' => { bullshit => 'params', go => 'here' }],
            gorge  => 'i should have just called this foo',
        );
    },
    undef,
    'regular roles with args can be applied, but args are ignored';

can_ok $a, 'gorge';
