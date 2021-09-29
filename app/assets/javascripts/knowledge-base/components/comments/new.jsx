/*global React*/
/*global ReactDOM*/
/*global $*/
var NewComment = createReactClass({
  getInitialState: function(){
    return({
      view: false,
      loading: false,
      content: '',
      focused: false
    });
  },
  componentDidMount: function(){
  },
  valid: function(){
    return (this.state.content != '');
  },
  handleChange: function(e){
    this.setState({content: e.target.value});
  },
  submitNote: function(e){
    e.preventDefault();
    this.handleSubmit(false);
  },
  cancelNote: function(e){
    e.preventDefault();
    this.setState({view: false});
  },
  handleSubmit: function(sendAsEmail){
    var _this=this;
    if (!this.state.loading){
      this.setState({loading: true});
      $.ajax({
        method: 'POST',
        url: '/universal/comments',
        dataType: 'JSON',
        data:{
          subject_type: this.props.subject_type,
          subject_id: this.props.subject_id,
          content: this.state.content,
          kind: 'normal',
          hide_private_comments: this.props.hidePrivateComments
        },
        success: function(data){
          _this.setState({content: '', loading: false, view: false});
          _this.props.updateCommentList(data);
        }
      });
    }
  },
  render: function(){
    return(  
      this.commentForm()
    );
  },
  commentForm: function(){
    if (this.state.view){
      return(
        <form>
          <div className="form-group">
            <textarea 
              className="form-control small text-info"
              ref='content'
              placeholder={this.props.newCommentPlaceholder}
              onChange={this.handleChange}
              onFocus={this.setFocus}
              onBlur={this.setFocus}
              style={{height: '100px'}}
              />
          </div>
          <div className="form-group">
            <div className="btn-group">
              <button className="btn btn-primary btn-sm" onClick={this.submitNote}><i className="fa fa-check" /> Save</button>
              <button className="btn btn-warning btn-sm" onClick={this.cancelNote}><i className="fa fa-times" /> Cancel</button>
            </div>
          </div>
        </form>
      );
    }else{
      return(
        <button className="btn btn-sm" onClick={this.addContent}>
          <i className="fa fa-file-text" /> {this.props.newCommentPlaceholder}
        </button>
      )
    }
  },
  addContent: function(){
    this.setState({view: true});
  },
  loadingIcon: function(send_icon){
    if (this.state.loading){
      return('fa fa-refresh fa-spin');
    }else{
      return(`fa fa-${send_icon}`);
    }
  },
  setFocus: function(){
    this.setState({focused: !this.state.focused});
  },
  focusStyle: function(){
    if (this.state.focused){
      return({backgroundColor: '#FFF'});
    }
  }
});