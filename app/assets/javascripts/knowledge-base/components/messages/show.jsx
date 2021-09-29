/*global React*/
/*global Autolinker*/
/*global $*/
/*global can*/
var Message = createReactClass({
  getInitialState: function(){
    return({message: null});
  },
  componentDidMount: function(){
    this.setState({message: this.props.message});
  },
  render: function(){
    if (this.state.message){
      return(
        <div className="col-sm-6">
          <div className="panel panel-info">
            <div className="panel-body">
              {this.status()}
              <div className="pull-right text-muted">
                {this.pinMessage()}
                {this.deleteMessage()}
              </div>
              {this.channel()}
              {this.subject()}
              {this.messageContent()}
              {this.tags()}
              <RelatedContent relatedContent={this.props.message.related_content} />
              <Comments 
                subject_type='KnowledgeBase::Message'
                subject_id={this.props.message.id}
                newCommentPosition='bottom'
                openComments={can(this.props.gs, 'edit_messages') || (this.props.gs.user && this.props.gs.user.id == this.props.message.user_id)}
                newCommentPlaceholder={this.props.newCommentPlaceholder ? this.props.newCommentPlaceholder : 'Post here...'}
                />
              <Attachments subjectId={this.props.message.id} subjectType='KnowledgeBase::Message' 
                new={can(this.props.gs, 'edit_messages') || (this.props.gs.user && this.props.gs.user.id == this.props.message.user_id)} />
              <div className="text-right text-info small">
                <small>
                  <MessageAuthor message={this.state.message} author_name={this.state.message.author} /> - {this.props.message.created}
                </small>
              </div>
            </div>
          </div>
        </div>
      );
    }else{
      return(null);
    }
  },
  channel: function(){
    if (this.props.gs && this.props.gs.channel && this.props.gs.keyword){
      return(
        <div className="text-warning" style={{marginRight: '10px'}}>
          <i className="fa fa-hashtag" />{this.state.message.channel}
        </div>
        );
    }
  },
  status: function(){
    if (this.state.message && this.state.message.status == 'pending'){
      var approveButton = null;
      if (can(this.props.gs, 'approve_messages')){
        approveButton = <div className="pull-right">
          <div className="btn-group">
            <button className="btn btn-xs btn-success" title="Approve this post" onClick={this._approveMessage}>
              <i className="fa fa-check" />
            </button>
            <button className="btn btn-xs btn-danger" title="Delete this post" onClick={this._rejectMessage}>
              <i className="fa fa-times" />
            </button>
          </div>
        </div>
      }
      return(
        <div className="alert alert-warning alert-sm text-center">
          {approveButton}
          Pending administrator approval
        </div>
      );
    }else if (this.state.message && this.state.message.status == 'closed'){
      return(
        <div className="alert alert-warning alert-sm text-center">
          This post has been rejected
        </div>
      );
    }
  },
  subject: function(){
    if (this.state.message.subject_name){
      return(<div className="small">{this.state.message.subject_name}: </div>);
    }
  },
  messageContent: function(){
    return(<h2 style={{marginBottom: '10px'}} dangerouslySetInnerHTML={{__html: Autolinker.link(this.state.message.message.replace(/(?:\r\n|\r|\n)/g, '<br />'))}} />);
  },
  pinned: function(){
    return(this.state.message.pinned);
  },
  pinIcon: function(){
    if (this.pinned()){
      return("fa fa-thumb-tack text-danger");
    }else{
      return("fa fa-thumb-tack");
    }
  },
  pinMessage: function(){
    if (can(this.props.gs, 'pin_messages')){
      return(<span style={{marginLeft: '10px'}}><i className={this.pinIcon()} onClick={this._pinMessage} style={{cursor: 'pointer'}}/></span>);
    }else if (this.pinned()){
      return(<span style={{marginLeft: '10px'}}><i className={this.pinIcon()} /></span>);
    }
  },
  _pinMessage: function(){
    if (can(this.props.gs, 'pin_messages')){
      var _this=this;
      $.ajax({
        type: 'PATCH',
        url: `/kb/messages/${this.state.message.id}/pin`,
        success: function(data){
          _this.setState({message: data});
        }
      }); 
    }
  },
  tags: function(){
    if (can(this.props.gs, 'edit_messages') && (this.props.display_tags != false)){
      return(<Tags subjectType="KnowledgeBase::Message" subjectId={this.props.message.id} tags={this.props.message.tags} />);
    }
  },
  deleteMessage: function(){
    if (can(this.props.gs, 'delete_messages')){
      return(<span style={{marginLeft: '10px'}}><i className="fa fa-trash" onClick={this._deleteMessage} style={{cursor: 'pointer'}}/></span>);
    }
  },
  _deleteMessage: function(){
    var _this=this;
    if (confirm('Are you sure you want to delete this message?')){
      $.ajax({
        type: 'DELETE',
        url: `/kb/messages/${this.state.message.id}`,
        success: function(data){
          _this.setState({message: null});
        }
      });
    }
  },
  _approveMessage: function(){
    this._updateStatus('active');
  },
  _rejectMessage: function(){
    this._updateStatus('closed');
  },
  _updateStatus: function(status){
    var _this=this;
    if (confirm(`Are you sure you want to ${status == 'active' ? 'approve' : 'reject'} this message?`)){
      $.ajax({
        type: 'PATCH',
        url: `/kb/messages/${this.state.message.id}/update_status`,
        data: {status: status},
        success: function(data){
          _this.setState({message: data.message});
        }
      });
    }
  }
});