/*global React*/
/*global ReactDOM*/
/*global Faye*/
/*global $*/
/*global _*/
var MessageList = createReactClass({
  getInitialState: function(){
    return({
      fayeListener: null,
      message: null,
      messageLines: 0,
      messages: [],
      loading: false,
      pastProps: null,
      pageNum: null
    });
  },
  init: function(){
    this.loadMessages();
  },
  componentDidMount: function(){
    if (this.props.fayeServer){
      var faye = new Faye.Client(this.props.fayeServer + '/faye');
      faye.subscribe(`/kb/${this.props.scopeId}/new`, this.receiveFaye);
    }
  },
  receiveFaye: function(e){
    if (e.channel==this.props.gs.channel){
      this.init();
    }
  },
  componentDidUpdate: function(){
    if (this.state.pastProps != JSON.stringify(this.props) && !this.state.loading){
      this.setState({pageNum: null});
      this.init();
    }
  },
  _changeMessage: function(e){
    this.setState({message: e.target.value, messageLines: e.target.value.split(/\r\n|\r|\n/).length});
  },
  render: function(){
    return(
      <div>
        {this.messageForm()}
        {this.messages()}
        <Pagination
          pagination={this.state.pagination}
          currentPage={this.state.pageNum}
          pageResults={this.pageResults}
          displayDescription={true}
          />
      </div>
    );
  },
  messages: function(){
    if (this.state.messages.length>0){
      var h = [];
      var gs=this.props.gs;
      var new_placeholder = (this.props.new_placeholder ? this.props.new_placeholder : 'New content...');
      var new_comment_placeholder = (this.props.new_comment_placeholder ? this.props.new_comment_placeholder : 'New content...');
      var display_tags = this.props.display_tags;
      _.each(this.state.messages, function(message){
        h.push(<Message
          message={message}
          insertMessage={this.insertMessage}
          gs={gs}
          key={message.id}
          new_placeholder={new_placeholder}
          newCommentPlaceholder={new_comment_placeholder}
          display_tags={display_tags}
          />);
      });
      return(<div className="row" ref="messageList">{h}</div>);
    }/*else{
      return(<div className="alert alert-info">Nothing to see here...</div>);
    }*/
  },
  loadMessages: function(page){
    if (!this.state.loading){
      if (page==undefined){page=1;}
      this.setState({loading: true});
      var _this=this;
      $.ajax({
        type: 'GET',
        url: `/kb/messages.json?page=${page}`,
        data: {channel: this.props.gs.channel, keyword: this.props.gs.keyword},
        success: function(data){
          _this.setState({
            messages: data.messages,
            pagination: data.pagination,
            loading: false,
            pastProps: JSON.stringify(_this.props),
            pageNum: page
          });
          /*_this.props.sgs('searching', false);*/
        }
      });
    }
  },
  pageResults: function(page){
    this.loadMessages(page);
    this.setState({pageNum: page});
  },
  messageForm: function(){
    if (can(this.props.gs, 'edit_messages') || this.props.post_new_content){
      return(<div>
        <form onSubmit={this._submitForm}>
          <div className="form-group">
            <textarea
              onChange={this._changeMessage}
              className="form-control"
              ref="textarea"
              placeholder={(this.props.new_placeholder ? this.props.new_placeholder : 'New content...')}
              style={{height: `${this.textAreaHeight()}px`}} />
          </div>
          {this.submitButton()}
        </form>
      </div>);
    }
  },
  _submitForm: function(e){
    e.preventDefault();
    if (this.state.message && !this.state.loading){
      var textarea = ReactDOM.findDOMNode(this.refs.textarea);
      var _this=this;
      this.setState({loading: true});
      $.ajax({
        type: 'POST',
        url: '/kb/messages',
        data: {message: {message: this.state.message}, channel: this.props.gs.channel},
        success: function(data){
          textarea.value='';
          textarea.focus();
          _this.setState({
            messages: data.messages,
            pagination: data.pagination,
            loading: false,
            message: null,
            pastProps: JSON.stringify(_this.props),
            pageNum: 1
          });
        }
      });
    }
  },
  textAreaHeight: function(){
    if (this.state.message){
      var newHeight = 40 + (this.state.messageLines-1)*20;
      if (newHeight>240){
        newHeight=240;
      }
      return newHeight
    }else{
      return 40;
    }
  },
  postIcon: function(){
    if (this.state.loading){
      return("fa fa-fw fa-refresh fa-spin");
    }else{
      return("fa fa-fw fa-send");
    }
  },
  submitButton: function(){
    if (this.state.message){
      return(<div className="form-group"><button className="btn btn-primary"><i className={this.postIcon()} /> Post</button></div>);
    }else{
      return(null);
    }
  }
})