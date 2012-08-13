package EPrints::Plugin::Screen::Layout::TwoColumn;

use strict;

use EPrints::Plugin::Screen::Layout;
our @ISA = qw/ EPrints::Plugin::Screen::Layout /;

sub new
{
        my( $class, %params ) = @_;

        my $self = $class->SUPER::new(%params);

        $self->{name} = "Widget Default 2-Column Layout";
        $self->{surround} = "Box";

        return $self;
}

sub render
{
	my( $self ) = @_;

	my $widgets = $self->{widgets};
	my $user = $self->{user};

	my $repo = $self->{repository};

	my $page = $repo->xml->create_document_fragment;
	$page->appendChild( $self->render_core_widgets( ) );

	my $widget_wrapper = $repo->xml->create_element( "div", "class"=>"meprints_widget_wrapper"); 
	$page->appendChild( $widget_wrapper );

	if( !$self->{static} && !(defined $repo->current_user && ( $user->get_id == $repo->current_user->get_id ) ) ){
		return $page;
	}

	my $user_widgets;
	if( $self->{static} )
	{
		$user_widgets = $user->get_profile_widgets();
	}
	else
	{
		$user_widgets = $user->get_homepage_widgets();
	}

	my $left_column = $repo->xml->create_element( "div", class => "ep_profile_column", id => "ep_profile_left_col" );
	$widget_wrapper->appendChild( $left_column );
	my $right_column = $repo->xml->create_element( "div", class => "ep_profile_column", id => "ep_profile_right_col" );
	$widget_wrapper->appendChild( $right_column );
	my $counter = 0;	# counter for the scriptaculous wrappers
	my $column = $left_column;
	my $colname = "left";
	foreach my $widget_id ( @$user_widgets )
	{	
		
		$counter++;
		
		my $plugin = $repo->plugin( "Screen::Widget::".$widget_id, processor => $self->{processor} );

		if( !defined $plugin ) 
		{
			$column->appendChild( $self->render_placeholder( "$widget_id") );
			next;
		}
		next if( defined $plugin->{enable} && !$plugin->{enable} );

		$plugin->{user} = $user;

		my $surround = $repo->plugin("Enclosure::Surround::".$self->{surround});
		$surround->{title} = $plugin->{title};
		$surround->{help} = $plugin->{help};
		$surround->{content} = $plugin->render();

		my $box = $surround->render();

		if( !defined $box )
		{
			$column->appendChild( $self->render_placeholder( "$widget_id") );
			next;
		}

		# wrapper for scriptaculous
		my $wrapper_style = "ep_column_item";
		my $wrapper = $repo->xml->create_element( "div", id=>"epprofile".$colname."_$counter", class => $wrapper_style );
		$column->appendChild( $wrapper );
		$wrapper->appendChild( $box );

		if( $column == $left_column )
		{
			$column = $right_column;
		}else{
			$column = $left_column;
		}
	}

	my $rel_path = $repo->config( "rel_path" );

	unless( $self->{static} )
	{
		# call to scriptaculous
		if($user->get_id() == $repo->current_user()->get_id())
		{
			$page->appendChild( $repo->make_javascript( <<JS_DRAGNDROP ) );

Sortable.create('ep_profile_leftcol', {containment: ['ep_profile_leftcol', 'ep_profile_rightcol'], tag: 'div', onUpdate: updateList, dropOnEmpty:true });
Sortable.create('ep_profile_rightcol', {containment: ['ep_profile_leftcol', 'ep_profile_rightcol'],tag: 'div', onUpdate: updateList, dropOnEmpty:true });

function updateList(el,eventobj) 
{ 
	var leftcol = document.getElementById( 'ep_profile_leftcol' );
	if( !leftcol )
		return;

	var l_nodes = leftcol.childNodes;
	var l_order = '';
	var is_first = 1;
	for(var i=0;i<l_nodes.length;i++)
	{
		if( l_nodes[i].id != null && l_nodes[i].id == '_internal_message_leftcol' )
		{
			l_nodes[i].parentNode.removeChild( l_nodes[i] );
		}
		else
		{
			var id = l_nodes[i].childNodes[0].id;

			if( id != null )
			{
				id = id.replace( 'ep_profile_', '' );

				if( is_first )
				{
					l_order += id;
					is_first = 0;
				}
				else
					l_order += ','+id;
			}
		}
	}

	if( l_order.length == 0 )
	{
		var exists = document.getElementById( '_internal_message_leftcol' );
		if( exists == null )
		{
			var msg = document.createElement( 'div' );
			msg.setAttribute( 'id', '_internal_message_leftcol' );
			msg.style.fontStyle = 'italic';
			msg.style.color = '#666666';
			msg.appendChild( document.createTextNode( 'You may drop your widgets here' ) );
			leftcol.appendChild( msg );
		}


	}
	
	var rightcol = document.getElementById( 'ep_profile_rightcol' );
	if( !rightcol )
		return;

	var r_nodes = rightcol.childNodes;
	var r_order = '';
	is_first = 1;
	for(var i=0;i<r_nodes.length;i++)
	{
		var id = r_nodes[i].childNodes[0].id;
		
		id = id.replace( 'ep_profile_', '' );

		if( is_first )
		{
			r_order += id;
			is_first = 0;
		}
		else
			r_order += ','+id;
	}
	
	var prefs = l_order +',__SEPARATOR__,' + r_order;
	
	new Ajax.Request('$rel_path/cgi/users/meprints/save',
		{
			method: 'post',
			parameters: { 
				prefs: prefs,
				leftcol: l_order,
				rightcol: r_order
			}
		});
	return true; 
};
JS_DRAGNDROP

			}
		}
	$widget_wrapper->appendChild($repo->xml->create_element("div", "style"=>"height:1px; width:100%; clear:both;"));
	$page->appendChild( $self->render_bottom_controls( ) );
	return $page;
}

sub get_layoutmgr_id
{
        return 'TwoColumn';
}


1;
