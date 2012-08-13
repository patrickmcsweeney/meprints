package EPrints::Plugin::Enclosure::Surround::Simple;

use strict;

use EPrints::Plugin;
our @ISA = qw/ EPrints::Plugin /;

sub new
{
        my( $class, %params ) = @_;

        my $self = $class->SUPER::new(%params);

        $self->{name} = "Widget Render Simple";

        return $self;
}

sub render
{
	my( $self, %options ) = @_;

	if( !defined $options{widget} ) 
	{ 
		EPrints::abort( "Plugin::Widget::Render::Simple::render called without a widget." );
	}
	if( !defined $options{session} ) 
	{ 
		EPrints::abort( "Plugin::Widget::Render::Simple::render called without a session." ); 
	}

	my $session = $options{session};
	my $widget = $options{widget};

	$options{title} = $widget->render_title();
	$options{content} = $widget->render_content();

	my $id = $options{id};
	my $contentid = $id."_content";

	my $div = $session->make_element( "div", id=>$id, style=>"padding: 5px;" );

	# Body	
	my $div_body = $session->make_element( "div", id=>$contentid );
	my $div_body_inner = $session->make_element( "div", id=>$contentid."_inner", style=>$options{content_style} );
	$div_body->appendChild( $div_body_inner );
	$div->appendChild( $div_body );
	
	my @widget_parts = split( /::/, $widget->get_id );
	my $widget_short_name = $widget_parts[$#widget_parts];
	if( grep( /^$widget_short_name$/, @{$session->get_repository->get_conf( 'user_profile_defaults' )} ) )
	{
		my $embed_link = $session->make_element( "a", title=>$session->phrase( "Plugin/Screen/User/Profile:widget_embed_help_title" ), class=>'meprints_embed_link', onclick=>"EPJS_blur(event); EPJS_toggleSlide('".$widget_short_name."_embed_help', false);" );
		#my $embed_link_img = $session->make_element( "img", src=>"/style/images/embed_chain.png", alt=>$session->phrase( "Plugin/Screen/User/Profile:widget_embed_help_title" ), border=>0 );
		#$embed_link->appendChild( $embed_link_img );
		$embed_link->appendChild( $session->html_phrase( "Plugin/Screen/User/Profile:widget_embed_help_title" ) );
		$div_body_inner->appendChild( $embed_link );

		my $div_id = "meprints_widget_$widget_short_name";
		my $js_url = $session->get_repository->get_conf( 'base_url' ).'/cgi/meprints/embed_js?userid='.$widget->{user}->get_id.'&widgetname='.$widget_short_name;
		my $css_url = $session->get_repository->get_conf( 'base_url' ).'/style/meprints_embed.css';
		my $embed_help = $session->make_element( "div", id=>$widget_short_name.'_embed_help', class=>'ep_summary_box_body', style=>'display: none;' );
		my $embed_help_inner = $session->make_element( "div", id=>$widget_short_name.'_embed_help_inner' );
		$embed_help_inner->appendChild( $session->html_phrase( "Plugin/Screen/User/Profile:widget_embed_help",
			div_id=>$session->make_text( $div_id ),
			js_url=>$session->make_text( $js_url ),
			css_url=>$session->make_text( $css_url ) ) );

		$embed_help->appendChild( $embed_help_inner );
		$div_body_inner->appendChild( $embed_help );
	}

	my $title = $session->make_element( "h2" );
	$title->appendChild( $options{title} );
	
	$div_body_inner->appendChild( $title );
	$div_body_inner->appendChild( $options{content} );
	
	return $div;
}

1;

