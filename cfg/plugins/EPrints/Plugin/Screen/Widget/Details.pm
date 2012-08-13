package EPrints::Plugin::Screen::Widget::Details;

use EPrints::Plugin::Screen::Widget;
@ISA = ( 'EPrints::Plugin::Screen::Widget' );

use strict;

sub new
{
	my( $class, %params ) = @_;
	
	my $self = $class->SUPER::new(%params);

	$self->{name} = "EPrints Profile System: User Details Widget";
	$self->{visible} = "all";
	$self->{advertise} = 1;

	$self->{surround} = 'Simple';
	$self->{render_title} = 0;
	$self->{show_in_controls} = 0;

	return $self;	
}

sub render_content
{
	my( $self ) = @_;

	my $div = $self->{session}->make_element( 'div', class => "meprints_details" );
	$div->appendChild( $self->{user}->render_citation( 'details' ) );

	return $div;
}

1;
