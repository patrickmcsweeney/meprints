package EPrints::Plugin::Screen::Widget::Thumbnail;

use EPrints::Plugin::Screen::Widget;

@ISA = ( 'EPrints::Plugin::Screen::Widget' );

use strict;

sub new
{
	my( $class, %params ) = @_;
	
	my $self = $class->SUPER::new( %params );
	
	if ( !$self->{session} )
	{
		$self->{session} = $self->{processor}->{session};
	}

	$self->{name} = "EPrints Profile System: User Image Widget";
	$self->{visible} = "all";
	$self->{advertise} = 1;

	$self->{render_title} = 0;
	$self->{show_in_controls} = 0;

	$self->{surround} = "Simple";

	return $self;
}

sub render_content
{
	my( $self ) = @_;

	return $self->{session}->make_element( "img", alt => "Profile Picture", src => $self->{user}->get_picture_url );
}

1;

