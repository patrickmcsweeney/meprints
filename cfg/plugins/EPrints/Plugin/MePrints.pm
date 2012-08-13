package EPrints::Plugin::MePrints;

use strict;
use warnings;

our @ISA = qw/ EPrints::Plugin /;

package EPrints::DataObj::User;

no warnings;

sub is_profile_visible
{
	my( $self ) = @_;

	return ($self->get_value( "real_profile_visibility" ) eq 'public');
}

sub get_url
{
	my( $self ) = @_;

	return $self->_get_url_default() if( !$self->{session}->get_repository->get_conf( "meprints_enabled" ) );

	return unless( $self->is_profile_visible );

	unless( $self->{session}->get_repository->get_conf( "meprints_profile_with_username" ) )
	{
		return $self->{session}->get_repository->get_conf( "base_url" )."/profile/".$self->get_id;
	}

	return $self->{session}->get_repository->get_conf( "base_url" )."/profile/".$self->get_value( "username" );
}

sub _get_url_default
{
        my( $self ) = @_;

        return $self->{session}->get_repository->get_conf( "http_cgiurl" )."/users/home?screen=User::View&userid=".$self->get_value( "userid" );
}

sub get_picture_path
{
	my( $self ) = @_;
	my $userpath = $self->_userid_to_path();
	return $self->{session}->get_repository->get_conf("archiveroot")."/meprints/$userpath/picture";
}

sub get_picture_url
{
	my( $self ) = @_;
	return $self->{session}->get_repository->get_conf("rel_path")."/cgi/meprints/thumbnail?userid=".$self->get_id;
}

sub remove_static
{
	my( $self ) = @_;
	EPrints::Utils::rmtree( $self->localpath( ) );
	return;
}

sub localpath
{
	my( $self ) = @_;
	my $userpath = $self->_userid_to_path();
	return $self->{session}->get_repository->get_conf("archiveroot")."/meprints/$userpath/profile";
}

sub generate_static
{
        my( $self ) = @_;

        $self->{session}->{preparing_static_page} = 1;

        $self->remove_static;

	my $full_path = $self->localpath();

	my @created = EPrints::Platform::mkdir( $full_path );

	my $layoutmgr = $self->{session}->plugin( "MePrints::Layout::TwoColumn",
							static => 1,
							user => $self 
	);

	unless( defined $layoutmgr )
	{
		$self->{session}->get_repository->log( "Error: failed to load the Widget Layout Manager." );
		return $self->{session}->html_phrase( "layoutmgr_error" );
	} 

	my $page = $self->{session}->make_doc_fragment;
# TODO phrase!!!
	my $title = $self->{session}->make_text( 'User Profile' );
	my $links = $self->{session}->make_doc_fragment();
	
	$page->appendChild( $layoutmgr->render() );
	
	$self->{session}->write_static_page(
		$full_path."/index",
		{title=>$title, page=>$page, head=>$links },
		"default"
	);

	delete $self->{session}->{preparing_static_page};
	
	return $page;
}

sub set_homepage_widgets
{
	my( $self, $widgets ) = @_;

	# i've seen a few race-conditions
	return 0 if( $self->{setting_homepage} );
	$self->{setting_homepage} = 1;

	$self->set_value( "homepage_preferences", $widgets );
	
	my $rc = $self->commit(1);
	delete $self->{setting_homepage};
	return $rc;
}

sub get_homepage_widgets
{
	my( $self ) = @_;

	my $widgets = $self->get_value( "homepage_preferences" );
	
	return $widgets if( scalar(@$widgets) );

	return $self->{session}->get_repository->get_conf( "user_homepage_defaults" );
}

sub get_profile_widgets
{
	my( $self ) = @_;

	return $self->{session}->get_repository->get_conf( "user_profile_defaults" );
}

sub _userid_to_path
{
        my( $self ) = @_;
        my $userid = $self->get_id;
        return unless( $userid =~ m/^\d+$/ );
        my( $a, $b, $c, $d );
        $d = $userid % 100;
        $userid = int( $userid / 100 );
        $c = $userid % 100;
        $userid = int( $userid / 100 );
        $b = $userid % 100;
        $userid = int( $userid / 100 );
        $a = $userid % 100;
        return sprintf( "%02d/%02d/%02d/%02d", $a, $b, $c, $d );
}

1;

