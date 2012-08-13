package EPrints::Plugin::Screen::Widget::QuickUpload;

use EPrints::Plugin::Screen::Widget;
@ISA = ( 'EPrints::Plugin::Screen::Widget' );

use strict;

sub new
{

	my( $class, %params ) = @_;

	my $self = $class->SUPER::new( %params );
	
	$self->{name} = "EPrints Profile System: Quick Upload";
        $self->{actions} = [qw/ quickupload /];
	$self->{visible} = "all";
	$self->{advertise} = 1;

	return $self;

}



sub allow_quickupload
{
        my ( $self ) = @_;

        return $self->allow( "create_eprint" );
}

sub action_quickupload
{
        my( $self ) = @_;

        my $ds = $self->{processor}->{session}->get_repository->get_dataset( "inbox" );

        my $user = $self->{session}->current_user;

        $self->{processor}->{eprint} = $ds->create_object( $self->{session}, {
                userid => $user->get_value( "userid" ) } );

        if( !defined $self->{processor}->{eprint} )
        {
                my $db_error = $self->{session}->get_database->error;
                $self->{processor}->{session}->get_repository->log( "Database Error: $db_error" );
                $self->{processor}->add_message(
                        "error",
                        $self->html_phrase( "db_error" ) );
                return;
        }

        $self->{processor}->{eprintid} = $self->{processor}->{eprint}->get_id;
        $self->{processor}->{screenid} = "EPrint::Edit";

}


sub render
{
	my( $self ) = @_;

	my $session = $self->{session};
	my $user = $self->{user};
	my $id = "QuickUpload";

	my $frag = $session->make_doc_fragment;

	my $form = $session->render_form( "POST", $session->get_repository->get_conf( "rel_path" )."/cgi/users/home");

	my $hidden_field = $session->make_element("input", "name"=>"screen", "id"=>"screen", "value"=>"Widget::QuickUpload", "type"=>"hidden");
	$form->appendChild( $hidden_field );

	#$hidden_field = $session->make_element("input", "name"=>"widget", "id"=>"widget", "value"=>"MePrints::Widget::QuickUpload", "type"=>"hidden");
	#$form->appendChild( $hidden_field );

	my $file_button = $session->make_element( "input",
		name => $id."_file",
		id => "filename",
		type => "file",
	);
	$form->appendChild( $file_button );

	$form->appendChild( $session->render_action_buttons(
		_class => "ep_form_button_bar",
		quickupload => $self->phrase( "add_file" ) ));

	$frag->appendChild( $form );

	return $frag;

}

sub action_quickupload
{
	my ( $self ) = @_;
	my $repo = $self->{session};

        my $eprint_ds = $repo->dataset( 'eprint' );
	my $eprint_data = {
				"eprint_status" => "inbox",
			 	"userid" => $repo->current_user->get_id(),
	};
	my $eprint = $eprint_ds->create_object( $repo, $eprint_data );

	unless( defined $eprint )
	{
		return;
	}

        my $doc_ds = $repo->get_dataset( 'document' );
	my $doc_data = { eprintid => $eprint->get_id };
        $doc_data->{format} = $repo->call( 'guess_doc_type',
                $repo,
                $repo->param( "QuickUpload"."_file" ) 
	);
        my $document = $doc_ds->create_object( $repo, $doc_data );

        unless( defined $document )
        {
                return;
        }

        my $success = EPrints::Apache::AnApache::upload_doc_file(
                $repo,
                $document,
                "QuickUpload"."_file" 
	);

        unless( $success )
        {
                $document->remove();
                return;
        }
print STDERR "FOO BAR BAZ!!!!\n";
	$repo->redirect($repo->get_conf( "rel_path" ).'/cgi/users/home?screen=EPrint::Edit&eprintid='.$eprint->get_id());

	return;
}


1;
