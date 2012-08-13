package EPrints::Plugin::Enclosure::Surround::Box;

use strict;

use EPrints::Plugin;
our @ISA = qw/ EPrints::Plugin /;

sub new
{
        my( $class, %params ) = @_;

        my $self = $class->SUPER::new(%params);

        $self->{name} = "Widget Render Box";

        return $self;
}


sub render
{
	my( $self, %options ) = @_;

	if( !defined $self->{session} ) { EPrints::abort( "Plugin::Widget::Render::Box::render called without a session." ); }
	if( !defined $self->{content} ) { EPrints::abort( "Plugin::Widget::Render::Box::render called without content." ); }
	if( !defined $self->{id} ) { EPrints::abort( "Plugin::Widget::Render::Box::render called without a id. Bad bad bad." ); }

	my $session = $self->{session};
	my $imagesurl = $session->get_repository->get_conf( "rel_path" );
	if( !defined $self->{show_icon_url} ) { $self->{show_icon_url} = "$imagesurl/style/images/plus.png"; }
	if( !defined $self->{hide_icon_url} ) { $self->{hide_icon_url} = "$imagesurl/style/images/minus.png"; }

	my $id = $self->{id};
		
	my $contentid = $id."_content";
	my $colbarid = $id."_colbar";
	my $barid = $id."_bar";
	my $div = $session->make_element( "div", class=>"meprints_box", id=>$id );

	# Title
	my $div_title = $session->make_element( "div", class=>"meprints_box_title" );
	$div->appendChild( $div_title );

	my $nojstitle = $session->make_element( "div", class=>"ep_no_js" );
	$nojstitle->appendChild( $session->xml->create_text_node( $self->{title} ) );
	$div_title->appendChild( $nojstitle );

	my $collapse_bar = $session->make_element( "div", class=>"ep_only_js", id=>$colbarid );
	$collapse_bar->appendChild( $session->make_text( $self->{title} ) );
	$div_title->appendChild( $collapse_bar );

	my $a = "true";
	my $b = "false";
	
	my $uncollapse_bar = $session->make_element( "div", class=>"ep_only_js", id=>$barid );
	my $uncollapse_link = $session->make_element( "a", id=>$barid, class=>"ep_box_collapse_link", onclick => "EPJS_blur(event); EPJS_toggleSlideScroll('${contentid}',false,'${id}');EPJS_toggle('${colbarid}',$a);EPJS_toggle('${barid}',$b);return false", href=>"#" );
	$uncollapse_link->appendChild( $session->make_element( "img", alt=>"+", src=>$self->{show_icon_url}, border=>0 ) );
	$uncollapse_link->appendChild( $session->make_text( " " ) );
	$uncollapse_link->appendChild($session->xml->create_text_node( $self->{title} ));
	$uncollapse_bar->appendChild( $uncollapse_link );
	$div_title->appendChild( $uncollapse_bar );

	# Body	
	my $div_body = $session->make_element( "div", class=>"meprints_box_body", id=>$contentid );
	my $div_body_inner = $session->make_element( "div", id=>$contentid."_inner", style=>$self->{content_style} );
	$div_body->appendChild( $div_body_inner );
	$div->appendChild( $div_body );
	$div_body_inner->appendChild( $self->{content} );

	if( $self->{collapsed} ) 
	{ 
		$collapse_bar->setAttribute( "style", "display: none" ); 
		$div_body->setAttribute( "style", "display: none" ); 
	}
	else
	{
		$uncollapse_bar->setAttribute( "style", "display: none" ); 
	}
		
	return $div;
}

1;

