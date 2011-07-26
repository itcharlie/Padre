package Padre::Wx::FBP::ReplaceInFiles;

## no critic

# This module was generated by Padre::Plugin::FormBuilder::Perl.
# To change this module edit the original .fbp file and regenerate.
# DO NOT MODIFY THIS FILE BY HAND!

use 5.008;
use strict;
use warnings;
use Padre::Wx ();
use Padre::Wx::Role::Main ();
use Padre::Wx::History::ComboBox ();

our $VERSION = '0.88';
our @ISA     = qw{
	Padre::Wx::Role::Main
	Wx::Dialog
};

sub new {
	my $class  = shift;
	my $parent = shift;

	my $self = $class->SUPER::new(
		$parent,
		-1,
		Wx::gettext("Replace in Files"),
		Wx::wxDefaultPosition,
		Wx::wxDefaultSize,
		Wx::wxDEFAULT_DIALOG_STYLE,
	);

	my $m_staticText2 = Wx::StaticText->new(
		$self,
		-1,
		Wx::gettext("Search &Term:"),
	);

	$self->{find_term} = Padre::Wx::History::ComboBox->new(
		$self,
		-1,
		"",
		Wx::wxDefaultPosition,
		Wx::wxDefaultSize,
		[
			"search",
		],
	);

	Wx::Event::EVT_TEXT(
		$self,
		$self->{find_term},
		sub {
			shift->refresh(@_);
		},
	);

	my $m_staticText21 = Wx::StaticText->new(
		$self,
		-1,
		Wx::gettext("Replace With:"),
	);

	$self->{replace_term} = Padre::Wx::History::ComboBox->new(
		$self,
		-1,
		"",
		Wx::wxDefaultPosition,
		Wx::wxDefaultSize,
		[
			"replace",
		],
	);

	Wx::Event::EVT_TEXT(
		$self,
		$self->{replace_term},
		sub {
			shift->refresh(@_);
		},
	);

	my $m_staticText3 = Wx::StaticText->new(
		$self,
		-1,
		Wx::gettext("Directory:"),
	);

	$self->{find_directory} = Padre::Wx::History::ComboBox->new(
		$self,
		-1,
		"",
		Wx::wxDefaultPosition,
		[ 250, -1 ],
		[
			"find_directory",
		],
	);

	$self->{directory} = Wx::Button->new(
		$self,
		-1,
		Wx::gettext("&Browse"),
		Wx::wxDefaultPosition,
		[ 50, -1 ],
	);

	Wx::Event::EVT_BUTTON(
		$self,
		$self->{directory},
		sub {
			shift->directory(@_);
		},
	);

	my $m_staticText4 = Wx::StaticText->new(
		$self,
		-1,
		Wx::gettext("File Types:"),
	);

	$self->{find_types} = Wx::ComboBox->new(
		$self,
		-1,
		"",
		Wx::wxDefaultPosition,
		Wx::wxDefaultSize,
		[],
	);

	my $m_staticline2 = Wx::StaticLine->new(
		$self,
		-1,
		Wx::wxDefaultPosition,
		Wx::wxDefaultSize,
		Wx::wxLI_HORIZONTAL,
	);

	$self->{find_regex} = Wx::CheckBox->new(
		$self,
		-1,
		Wx::gettext("&Regular Expression"),
		Wx::wxDefaultPosition,
		Wx::wxDefaultSize,
	);

	$self->{find_case} = Wx::CheckBox->new(
		$self,
		-1,
		Wx::gettext("&Case Sensitive"),
		Wx::wxDefaultPosition,
		Wx::wxDefaultSize,
	);

	my $m_staticline1 = Wx::StaticLine->new(
		$self,
		-1,
		Wx::wxDefaultPosition,
		Wx::wxDefaultSize,
		Wx::wxLI_HORIZONTAL,
	);

	$self->{replace} = Wx::Button->new(
		$self,
		Wx::wxID_OK,
		Wx::gettext("&Replace"),
		Wx::wxDefaultPosition,
		Wx::wxDefaultSize,
	);
	$self->{replace}->SetDefault;

	$self->{cancel} = Wx::Button->new(
		$self,
		Wx::wxID_CANCEL,
		Wx::gettext("Cancel"),
		Wx::wxDefaultPosition,
		Wx::wxDefaultSize,
	);

	my $bSizer4 = Wx::BoxSizer->new(Wx::wxHORIZONTAL);
	$bSizer4->Add( $self->{find_directory}, 1, Wx::wxALIGN_CENTER_VERTICAL | Wx::wxALL | Wx::wxEXPAND, 5 );
	$bSizer4->Add( $self->{directory}, 0, Wx::wxALIGN_CENTER_VERTICAL | Wx::wxALIGN_RIGHT | Wx::wxRIGHT, 5 );

	my $fgSizer2 = Wx::FlexGridSizer->new( 2, 2, 0, 0 );
	$fgSizer2->AddGrowableCol(1);
	$fgSizer2->SetFlexibleDirection(Wx::wxBOTH);
	$fgSizer2->SetNonFlexibleGrowMode(Wx::wxFLEX_GROWMODE_SPECIFIED);
	$fgSizer2->Add( $m_staticText2, 0, Wx::wxALIGN_CENTER_VERTICAL | Wx::wxALL, 5 );
	$fgSizer2->Add( $self->{find_term}, 0, Wx::wxALIGN_CENTER_VERTICAL | Wx::wxALL | Wx::wxEXPAND, 5 );
	$fgSizer2->Add( $m_staticText21, 0, Wx::wxALIGN_CENTER_VERTICAL | Wx::wxALL, 5 );
	$fgSizer2->Add( $self->{replace_term}, 0, Wx::wxALL | Wx::wxEXPAND, 5 );
	$fgSizer2->Add( $m_staticText3, 0, Wx::wxALIGN_CENTER_VERTICAL | Wx::wxALL, 5 );
	$fgSizer2->Add( $bSizer4, 1, Wx::wxEXPAND, 5 );
	$fgSizer2->Add( $m_staticText4, 0, Wx::wxALIGN_CENTER_VERTICAL | Wx::wxALL, 5 );
	$fgSizer2->Add( $self->{find_types}, 0, Wx::wxALIGN_CENTER_VERTICAL | Wx::wxALL | Wx::wxEXPAND, 5 );

	my $buttons = Wx::BoxSizer->new(Wx::wxHORIZONTAL);
	$buttons->Add( $self->{replace}, 0, Wx::wxALL, 5 );
	$buttons->Add( 20, 0, 1, Wx::wxEXPAND, 5 );
	$buttons->Add( $self->{cancel}, 0, Wx::wxALL, 5 );

	my $vsizer = Wx::BoxSizer->new(Wx::wxVERTICAL);
	$vsizer->Add( $fgSizer2, 1, Wx::wxEXPAND, 5 );
	$vsizer->Add( $m_staticline2, 0, Wx::wxALL | Wx::wxEXPAND, 5 );
	$vsizer->Add( $self->{find_regex}, 0, Wx::wxALL, 5 );
	$vsizer->Add( $self->{find_case}, 0, Wx::wxALL, 5 );
	$vsizer->Add( $m_staticline1, 0, Wx::wxALL | Wx::wxEXPAND, 5 );
	$vsizer->Add( $buttons, 0, Wx::wxEXPAND, 5 );

	my $hsizer = Wx::BoxSizer->new(Wx::wxHORIZONTAL);
	$hsizer->Add( $vsizer, 1, Wx::wxALL | Wx::wxEXPAND, 5 );

	$self->SetSizer($hsizer);
	$self->Layout;
	$hsizer->Fit($self);

	return $self;
}

sub find_term {
	$_[0]->{find_term};
}

sub replace_term {
	$_[0]->{replace_term};
}

sub find_directory {
	$_[0]->{find_directory};
}

sub find_types {
	$_[0]->{find_types};
}

sub find_regex {
	$_[0]->{find_regex};
}

sub find_case {
	$_[0]->{find_case};
}

sub replace {
	$_[0]->{replace};
}

sub refresh {
	$_[0]->main->error('Handler method refresh for event find_term.OnText not implemented');
}

sub directory {
	$_[0]->main->error('Handler method directory for event directory.OnButtonClick not implemented');
}

1;

# Copyright 2008-2011 The Padre development team as listed in Padre.pm.
# LICENSE
# This program is free software; you can redistribute it and/or
# modify it under the same terms as Perl 5 itself.

