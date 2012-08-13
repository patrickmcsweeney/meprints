package EPrints::Plugin::MePrints::Widget::IRStats::DownloadGraph;

use EPrints::Plugin::MePrints::Widget;
@ISA = ( 'EPrints::Plugin::MePrints::Widget' );

use strict;

sub new
{
	
	my( $class, %params ) = @_;
	
	my $self = $class->SUPER::new( %params );
	
	$self->{name} = "EPrints Profile System: IRStats";

        unless( EPrints::Utils::require_if_exists( "IRStats" ) && EPrints::Utils::require_if_exists( "IRStats::Date" ) )
        {
                $self->{visible} = "";
		$self->{advertise} = 0;
		$self->{enable} = 0;
                $self->{error} = "Failed to load required module MePrints::Widget::IRStats";
		return $self;
        }
	
	if ( !$self->{session} )
	{
		$self->{session} = $self->{processor}->{session};
	}

	$self->{visible} = "all";
	$self->{advertise} = 1;
	$self->{view_name} = 'MonthlyDownloadsGraph';
	$self->{period} = '-6m';
	$self->{chart_width} = '325';

	if ( defined $self->{session} )
        {
                my $conf = $self->{session}->get_repository->get_conf( 'irstats_widget' );

		if ( defined $conf )
		{
                        $self->{view_name} = $conf->{view_name} if( defined $conf->{view_name} );
			$self->{period} = $conf->{period} if( defined $conf->{period} );
			$self->{chart_width} = $conf->{chart_width} if( defined $conf->{chart_width} );
                }
        }

	return $self;

}

sub render_content
{

	my( $self ) = @_;

	my $session = $self->{session};
	my $user = $self->{user};

	my $period = $self->{period};
	my $start_date;
	my $end_date;
	if ( $period =~ /^-([0-9]+)m$/ )
	{
		my $months = $1;
		my $end_date_obj = IRStats::Date->new();
		my $start_date_obj = $end_date_obj->clone;

		foreach ( 1 .. $months )
		{
			$start_date_obj->decrement( 'month' );
		}

		$start_date_obj->increment( 'day' );
		
		$start_date = $start_date_obj->render( 'numerical' );
		$end_date = $end_date_obj->render( 'numerical' );
	}

	my $irstats = IRStats->new( eprints_session => $session );
	my $conf = $irstats->get_conf;
	my $param_hash = { view => $self->{view_name}, start_date => $start_date, end_date => $end_date, eprints => 'userid_'.$user->get_id };
	my $params = IRStats::Params->new( $conf, $param_hash );
	my $view_name = "IRStats::View::".$self->{view_name};
	
	my $frag = $session->make_doc_fragment;

	if(EPrints::Utils::require_if_exists( $view_name )){
		$frag->appendChild($session->make_text("Unable to load ".$view_name));
		return $frag;		
	}
        
	my $view = $view_name->new( $params, $session->get_database );

	my $chart = $session->make_element( "img", src => $self->{session}->get_repository->get_conf( 'irstats_widget' )->{irstats_url}.$view->get( 'visualisation' )->{filename}, width => $self->{chart_width}.'px' );
	$frag->appendChild( $chart );

	return $frag;

}

1;
