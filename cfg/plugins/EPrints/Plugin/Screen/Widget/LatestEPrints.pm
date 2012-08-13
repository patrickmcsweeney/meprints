package EPrints::Plugin::Screen::Widget::LatestEPrints;

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

	$self->{name} = "EPrints Profile System: Published List Widget";
	$self->{visible} = "all";
	$self->{advertise} = 1;

	$self->{max_display} = 10;
	
	return $self;
}

sub render
{
	my( $self ) = @_;

	my $session = $self->{session};
	my $user = $self->{user};

	my $frag = $session->make_doc_fragment;

	my $ds = $session->get_repository->get_dataset( "archive" );
	
	my $list = $user->get_owned_eprints($ds);
	$list = $list->reorder("-datestamp");

	

	if ( $list->count )
	{
		
		my $itemlist = $session->make_element( "ol" );
		
		foreach ( $list->get_records ( 0, $self->{max_display} ) )
		{
			my $eprintlink = $session->render_link( $session->get_repository->get_conf( "base_url" )."/".$_->get_id );
			$eprintlink->appendChild( $session->make_text( $_->get_value( "title" ) ) );
			my $eprintitem = $session->make_element( "li" );
			$eprintitem->appendChild( $eprintlink );
			$itemlist->appendChild( $eprintitem );
		}

		$frag->appendChild( $itemlist );
	}
	else
	{
		$frag->appendChild( $self->html_phrase( "noitems" ) );
	}

	return $frag;

}

1;
