package Bread::Board;
use v5.16;
use warnings;
use mop;

use Carp 'confess';
use Scalar::Util 'blessed';

use Bread::Board::Service;

class Dependency with Bread::Board::Traversable {

    has $service_path   is ro;
    has $service_params is ro;    
    has $service_name   is ro, lazy = $_->_build_service_name;
    has $service        is ro, lazy = $_->_build_service;

    method has_service_path   { defined $service_path   }
    method has_service_params { defined $service_params }

    submethod _build_service_name {
        ($self->has_service_path)
            || confess "Could not determine service name without service path";
        (split '/' => $service_path)[-1];
    }

    submethod _build_service {
        ($self->has_service_path)
            || confess "Could not fetch service without service path";
        $self->fetch($service_path);
    }

    method get       { $service->get( @_ )       }
    method is_locked { $service->is_locked( @_ ) }
    method lock      { $service->lock( @_ )      }
    method unlock    { $service->unlock( @_ )    }
}

=pod

package Bread::Board::Dependency;
use Moose;

use Bread::Board::Service;

with 'Bread::Board::Traversable';

has 'service_path' => (
    is        => 'ro',
    isa       => 'Str',
    predicate => 'has_service_path'
);

has 'service_name' => (
    is      => 'ro',
    isa     => 'Str',
    lazy    => 1,
    default => sub {
        my $self = shift;
        ($self->has_service_path)
            || confess "Could not determine service name without service path";
        (split '/' => $self->service_path)[-1];
    }
);

has 'service_params' => (
    is        => 'ro',
    isa       => 'HashRef',
    predicate => 'has_service_params'
);

has 'service' => (
    is       => 'ro',
    does     => 'Bread::Board::Service | Bread::Board::Dependency',
    lazy     => 1,
    default  => sub {
        my $self = shift;
        ($self->has_service_path)
            || confess "Could not fetch service without service path";
        $self->fetch($self->service_path);
    },
    handles  => [ 'get', 'is_locked', 'lock', 'unlock' ]
);

__PACKAGE__->meta->make_immutable;

no Moose; 1;

=cut

__END__

=pod

=head1 DESCRIPTION

=head1 METHODS

=over 4

=item B<get>

=item B<has_service_path>

=item B<is_locked>

=item B<lock>

=item B<service>

=item B<service_name>

=item B<service_path>

=item B<unlock>

=back

=head1 BUGS

All complex software has bugs lurking in it, and this module is no
exception. If you find a bug please either email me, or add the bug
to cpan-RT.

=cut
