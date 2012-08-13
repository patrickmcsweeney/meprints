
######################################################################
#
#  MePrints configuration
#
#  All About MEPrints is a JISC rapid innovations project to build a
#  user profile system for EPrints. The extension we have developed is
#  called MePrints. This configuration file lets you control how the
#  MePrints extension works in your repository.
#
# For an overview of MePrints, see:
# http://wiki.eprints.org/w/MePrintsOverview 
#
# For technical instructions, including troubleshooting, see:
# http://wiki.eprints.org/w/MePrintsInstall
#
######################################################################


# Maps the default EPrints' Profile page to MePrints'
$c->{plugins}->{"Screen::User::View"}->{appears}->{key_tools} = undef;
$c->{plugin_alias_map}->{"Screen::User::View"} = "Screen::User::Homepage";

# Use MePrints' homepage as first screen after logging in
$c->{plugins}->{"Screen::FirstTool"}->{params}->{default} = "User::Homepage";

# Allow repo.ac.uk/profile/XYZ urls
push( @{$c->{rewrite_exceptions}}, "/profile/" );

# Set to "1" to use username eg repository.ac.uk/profile/sf2 instead of userid repository.ac.uk/profile/1234
$c->{meprints_profile_with_username} = 0;

# Widget layout for all public profile pages.
# This layout can only be changed here.
# The special __SEPARATOR__ token indicates where the 
# widgets should be split across columns (note: only
# 2 column layout possible)
$c->{user_profile_defaults} = [
	'LatestEPrints',
	'IRStats::DownloadGraph',
	'__SEPARATOR__',
	'Repostats::TopTen',
];

# 1 means profiles are public by default, 0 means they are private
# use value "public" or "private"
$c->{default_profile_behavior} = "private";

# Default widget layout for user homepages.
# Users can customise their widget layout by adding,
# removing and moving widgets (the individual user
# layout is stored in the homepage_preferences field
# defined below).
# The special __SEPARATOR__ token indicates where the 
# widgets should be split across columns (note: only
# 2 column layout possible)
$c->{user_homepage_defaults} = [
	'QuickUpload',
	'LatestEPrints',
];

$c->{irstats_widget}= {
	view_name => "MonthlyDownloadsGraph",
	period=> "-6m",
	chart_width => '325',
	irstats_url=>$c->{base_url}.'/irstats/graphs/'
};

# Add user profile search. This will only search public
# user profiles.
$c->{search}->{user_public} =
{
        search_fields => [
                { meta_fields => [ "name" ] },
                { meta_fields => [ "username" ] },
                { meta_fields => [ "expertise" ] },
                { meta_fields => [ "qualifications" ] },
                { meta_fields => [ "dept" ] },
                { meta_fields => [ "org" ] },
	],

        citation => "default",
        page_size => 20,
        order_methods => {
                "byname"         =>  "name/joined",
                "byjoin"         =>  "joined/name",
                "byrevjoin"      =>  "-joined/name",
                "bytype"         =>  "usertype/name",
        },
        default_order => "byname",
        show_zero_results => 1,
};

# Add user profile browse views. This will only include
# public user profiles
@{$c->{browse_views}} = (@{$c->{browse_views}}, (

        {
                id => "user_expertise",
		dataset => "public_profile_users",
                menus => [
                        {
                                fields => [ "expertise" ],
				hide_empty => 1,
                                reverse_order => 1,
                                allow_null => 0,
                                new_column_at => [10,10],
                        }
                ],
                order => "name",
                variations => [	"dept" ],
        },
        {
                id => "user_dept",
		dataset => "public_profile_users",
                menus => [
                        {
                                fields => [ "dept" ],
				hide_empty => 1,
                                reverse_order => 1,
                                allow_null => 0,
                                new_column_at => [10,10],
                        }
                ],
                order => "name",
        },
));

# Add extra metadata fields for user profiles
@{ $c->{fields}->{user} } = ( @{ $c->{fields}->{user} }, (
	{
	    	'name' => 'homepage_preferences',
		'type' => 'text',
		'multiple' => 1,
	    	'show_in_html' => 0,
	},
	{
		'name' => 'jobtitle',
		'type' => 'text',
	},
	{
		'name' => 'expertise',
		'type' => 'text',
		'multiple' => 1,
		'input_cols' => 30,
		'input_boxes' => 6,
		'browse_link' => 'user_expertise',
	},
	{
		'name' => 'biography',
		'type' => 'longtext',
	},
	{
		'name' => 'qualifications',
		'type' => 'longtext',
	},
	{
		'name' => 'real_profile_visibility',
		'type' => 'set',
		'options' => [
			   'public',
			   'private'
			 ],
		'input_style' => 'radio',
	},
	{
		'name' => 'user_profile_visibility',
		'type' => 'set',
		'options' => [
			   'public',
			   'private'
			 ],
		'input_style' => 'radio',
	},
));

# Add virtual dataset of users who have opted to have their
# profile page publically viewable. This is used by the 
# user profile search and browse views.
$c->{datasets}->{public_profile_users} = {
        name => "public_profile_users",
        virtual => 1,
        class => "EPrints::DataObj::User",
        confid => "user",
        sqlname => "user",
        index => 1,
        filters => [{
                meta_fields => ['real_profile_visibility'],
                value => 'public',
                describe => 0
        }],
        dataset_id_field => 'real_profile_visibility'
};


