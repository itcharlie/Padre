package Padre::Wx::CPAN2;

use 5.008;
use strict;
use warnings;
use Padre::Constant        ();
use Padre::Role::Task      ();
use Padre::Wx::Role::View  ();
use Padre::Wx              ();
use Padre::Task::CPAN2     ();
use Padre::Wx::Role::Dwell ();
use Padre::Wx::FBP::CPAN   ();
use Padre::Logger qw(TRACE);

our $VERSION = '0.91';
our @ISA     = qw{
	Padre::Role::Task
	Padre::Wx::Role::View
	Padre::Wx::Role::Dwell
	Padre::Wx::FBP::CPAN
};

# Constructor
sub new {
	my $class = shift;
	my $main  = shift;
	my $panel = shift || $main->right;
	my $self  = $class->SUPER::new($panel);

	# Set up column sorting
	$self->{sort_column} = 0;
	$self->{sort_desc}   = 0;

	# Setup columns
	my @column_headers = (
		Wx::gettext('Distribution'),
		Wx::gettext('Author'),
	);
	my $index = 0;
	for my $column_header (@column_headers) {
		$self->{list}->InsertColumn( $index++, $column_header );
	}

	# Column ascending/descending image
	my $images = Wx::ImageList->new( 16, 16 );
	$self->{images} = {
		asc => $images->Add(
			Wx::ArtProvider::GetBitmap(
				'wxART_GO_UP',
				'wxART_OTHER_C',
				[ 16, 16 ],
			),
		),
		desc => $images->Add(
			Wx::ArtProvider::GetBitmap(
				'wxART_GO_DOWN',
				'wxART_OTHER_C',
				[ 16, 16 ],
			),
		),
		file => $images->Add(
			Wx::ArtProvider::GetBitmap(
				'wxART_NORMAL_FILE',
				'wxART_OTHER_C',
				[ 16, 16 ],
			),
		),
	};
	$self->{list}->AssignImageList( $images, Wx::IMAGE_LIST_SMALL );

	# Tidy the list
	Padre::Util::tidy_list( $self->{list} );

	# Create the search control menu
	$self->{search}->SetMenu( $self->new_menu );

	return $self;
}





######################################################################
# Padre::Wx::Role::View Methods

sub view_panel {
	return 'right';
}

sub view_label {
	shift->gettext_label(@_);
}

sub view_close {
	$_[0]->main->show_cpan_explorer(0);
}

sub view_start {
	$_[0]->{synopsis}->Disable;
	$_[0]->{changes}->Disable;
}

sub view_stop {
	my $self = shift;

	# Clear, reset running task and stop dwells
	$self->clear;
	$self->task_reset;
	$self->dwell_stop('refresh'); # Just in case

	return;
}

#####################################################################
# General Methods

# We need to create the menu whenever our locale changes
sub new_menu {
	my $self = shift;
	my $menu = Wx::Menu->new;

	Wx::Event::EVT_MENU(
		$self,
		$menu->Append(
			-1,
			Wx::gettext('Search in recent'),
		),
		sub {
		},
	);

	return $menu;
}

# Sets the focus on the search field
sub focus_on_search {
	$_[0]->{search}->SetFocus;
}

sub gettext_label {
	Wx::gettext('CPAN Explorer');
}

# Clear everything...
sub clear {
	my $self = shift;

	$self->{list}->DeleteAllItems;

	return;
}

# Nothing to implement here
sub relocale {
	return;
}

sub refresh {
	my $self = shift;
	my $command = shift || Padre::Task::CPAN2::CPAN_SEARCH;

	# Abort any in-flight checks
	$self->task_reset;

	# Start a background CPAN command task
	$self->task_request(
		task    => 'Padre::Task::CPAN2',
		command => $command,
		query   => lc( $self->{search}->GetValue ),
	);

	return 1;
}

sub task_finish {
	my $self = shift;
	my $task = shift;
	$self->{model} = Params::Util::_ARRAY0( $task->{model} ) or return;
	$self->render;
}

sub render {
	my $self = shift;

	# Clear if needed. Please note that this is needed
	# for sorting
	$self->clear;

	return unless $self->{model};

	# Update the list sort image
	$self->set_icon_image( $self->{sort_column}, $self->{sort_desc} );

	my $list = $self->{list};
	$self->_sort_model();
	my $model = $self->{model};

	my $index = 0;
	for my $rec (@$model) {

		# Add a CPAN distribution and author as a row to the list
		$list->InsertImageStringItem( $index, $rec->{documentation}, $self->{images}{file} );
		$list->SetItemData( $index, $index );
		$list->SetItem( $index++, 1, $rec->{author} );
	}

	# Tidy the list
	Padre::Util::tidy_list($list);

	return 1;
}

sub _sort_model {
	my ($self) = @_;

	my @model = @{ $self->{model} };
	if ( $self->{sort_column} == 0 ) {

		# Sort by status
		@model = sort { $a->{distribution} cmp $b->{distribution} } @model;

	} elsif ( $self->{sort_column} == 1 ) {

		# Sort by path
		@model = sort { $a->{author} cmp $b->{author} } @model;
	} else {
		TRACE( "sort_column: " . $self->{sort_column} . " is not implemented" ) if DEBUG;
	}

	if ( $self->{sort_desc} ) {

		# reverse the sorting
		@model = reverse @model;
	}

	$self->{model} = \@model;
}

#####################################################################
# Event Handlers

# Called when a CPAN list column is clicked
sub on_list_column_click {
	my ( $self, $event ) = @_;

	my $column   = $event->GetColumn;
	my $prevcol  = $self->{sort_column};
	my $reversed = $self->{sort_desc};
	$reversed = $column == $prevcol ? !$reversed : 0;
	$self->{sort_column} = $column;
	$self->{sort_desc}   = $reversed;

	# Reset the previous column sort image
	$self->set_icon_image( $prevcol, -1 );

	$self->render;

	return;
}

sub set_icon_image {
	my ( $self, $column, $image_index ) = @_;

	my $item = Wx::ListItem->new;
	$item->SetMask(Wx::LIST_MASK_IMAGE);
	$item->SetImage($image_index);
	$self->{list}->SetColumn( $column, $item );

	return;
}

# Called when a CPAN list item is selected
sub on_list_item_selected {
	my ( $self, $event ) = @_;

	my $module = $event->GetLabel;

	require LWP::UserAgent;
	my $ua = LWP::UserAgent->new;
	$ua->timeout(10);
	$ua->env_proxy unless Padre::Constant::WIN32;
	my $url      = "http://api.metacpan.org/v0/pod/$module?content-type=text/x-pod";
	my $response = $ua->get($url);
	unless ( $response->is_success ) {
		TRACE( sprintf( "Got '%s for %s", $response->status_line, $url ) )
			if DEBUG;
		return;
	}

	my $pod = $response->decoded_content;
	$self->{doc}->load_pod($pod);
	my ( $synopsis, $section ) = ( '', '' );
	for my $pod_line ( split /^/, $pod ) {
		if ( $pod_line =~ /^=head1\s+(\S+)/ ) {
			$section = $1;
		} elsif ( $section eq 'SYNOPSIS' ) {
			$synopsis .= $pod_line;
		}
	}
	if ( length $synopsis > 0 ) {
		$self->{synopsis}->Enable;
	} else {
		$self->{synopsis}->Disable;
	}
	$self->{SYNOPSIS} = $synopsis;

	return;
}

# Called when the synopsis is clicked
sub on_synopsis_click {
	my ( $self, $event ) = @_;
	return unless $self->{SYNOPSIS};

	# Open a new Perl document containing the SYNOPSIS text
	$self->main->new_document_from_string( $self->{SYNOPSIS}, 'application/x-perl' );

	return;
}

# Called when search text control is changed
sub on_search_text {
	$_[0]->main->cpan_explorer->dwell_start( 'refresh', 333 );
}

# Called when search cancel button is clicked
sub on_search_cancel {
	my $self = shift;

	# Clear the search control, stop the refresh dwell, and trigger it
	# immediately
	$self->{search}->SetValue('');
	$self->dwell_stop('refresh');
	$self->on_search_text;
}

1;

# Copyright 2008-2011 The Padre development team as listed in Padre.pm.
# LICENSE
# This program is free software; you can redistribute it and/or
# modify it under the same terms as Perl 5 itself.