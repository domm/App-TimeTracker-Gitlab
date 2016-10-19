package App::TimeTracker::Command::Gitlab;
use strict;
use warnings;
use 5.010;

# ABSTRACT: App::TimeTracker Gitlab plugin
use App::TimeTracker::Utils qw(error_message warning_message);

our $VERSION = "1.000";

use Moose::Role;
use HTTP::Tiny;
use JSON::XS qw(encode_json decode_json);
use Path::Class;

has 'issue' => (
    is            => 'rw',
    isa           => 'Str',
    documentation => 'gitlab issue',
    predicate     => 'has_issue'
);

has 'gitlab_client' => (
    is         => 'rw',
    isa        => 'Maybe[HTTP::Tiny]',
    lazy_build => 1,
    traits     => ['NoGetopt'],
);

sub _build_gitlab_client {
    my $self   = shift;
    my $config = $self->config->{gitlab};

    unless ( $config->{url} && $config->{token} ) {
        error_message(
            "Please configure Gitlab in your TimeTracker config (needs url & token)"
        );
        return;
    }

    return HTTP::Tiny->new(default_headers=>{
        'PRIVATE-TOKEN'=> $self->config->{gitlab}{token},
    });
}

has 'project_id' => (
    is=>'ro',
    isa=>'Int',
    documentation=>'The ID of this project',
    lazy_build=>1,
);

sub _build_project_id {
    my $self = shift;
    return $self->config->{gitlab}{project_id} if $self->config->{gitlab}{project_id};
    my $name = $self->config->{project};
    my $namespace = $self->config->{gitlab}{namespace} || '' ;
    if ($name && $namespace) {
        return join('%2F',$namespace, $name);
    }
    error_message("Please set either project_id, or project and namespace");
    return
}

before [ 'cmd_start', 'cmd_continue', 'cmd_append' ] => sub {
    my $self = shift;
    return unless $self->has_issue;

    my $issuename = 'issue#' . $self->issue;
    $self->insert_tag($issuename);

    my $issue = $self->_call('GET','projects/validad%2FApp-TimeTracker-Gitlab/issues?iid='.$self->issue);
    my $name = $issue->[0]{title};

    if ( defined $self->description ) {
        $self->description( $self->description . ' ' . $name );
    }
    else {
        $self->description($name);
    }

    if ( $self->meta->does_role('App::TimeTracker::Command::Git') ) {
        my $branch = $self->issue;
        if ($name) {
            $branch = $self->safe_branch_name($self->issue.' '.$name);
        }
        $branch=~s/_/-/g;
        $self->branch( lc($branch) ) unless $self->branch;
    }
};

#after [ 'cmd_start', 'cmd_continue', 'cmd_append' ] => sub {
#    my $self = shift;
#    TODO: do we want to do something after stop?
#};

sub _call {
    my ($self,$method,  $endpoint, $args) = @_;

    my $url = $self->config->{gitlab}{url}.'/api/v3/'.$endpoint;
    my $res = $self->gitlab_client->request($method,$url);

    if ($res->{success}) {
        my $data = decode_json($res->{content});
        return $data;
    }
    error_message(join(" ",$res->{status},$res->{reason}));
}

sub App::TimeTracker::Data::Task::gitlab_issue {
    my $self = shift;
    foreach my $tag ( @{ $self->tags } ) {
        next unless $tag =~ /^issue#(\d+)/;
        return $1;
    }
}

no Moose::Role;
1;

__END__


