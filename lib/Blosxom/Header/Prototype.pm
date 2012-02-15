package Blosxom::Header::Prototype;
use strict;
use warnings;
use Carp;
use Scalar::Util qw(refaddr);

{
    my %prototype_of;

    sub can {
        my $self   = shift;
        my $method = shift;
        my $id     = refaddr( $self );

        return exists $prototype_of{ $id }{ $method };
    }

    sub new {
        my $class  = shift;
        my %method = @_;
        my $self   = bless \do{ my $anon_scalar }, $class;
        my $id     = refaddr( $self ); 

        $prototype_of{ $id } = \%method;

        return $self;
    }

    sub AUTOLOAD {
        my $self = shift;
        my @args = @_;
        my $id   = refaddr( $self ); 

        ( my $method = our $AUTOLOAD ) =~ s{.*::}{}o;

        if ( $self->can( $method ) ) {
            my $code_ref = $prototype_of{ $id }{ $method };
            return $code_ref->( @args );
        }

        croak qq{Can't locate object method "$method" via package } .
              __PACKAGE__;
    }

    sub DESTROY {
        my $self = shift;
        my $id   = refaddr( $self );
        
        delete $prototype_of{ $id };

        return;
    }
}

1;

