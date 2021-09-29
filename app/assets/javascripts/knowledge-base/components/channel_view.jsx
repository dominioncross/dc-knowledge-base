/*global React*/
/*global ReactDOM*/
/*global $, createReactClass*/
var KnowledgeBaseChannel = createReactClass({
  
  getInitialState: function(){
    return({
      gs: {}, //global state
      sgs: this.setGlobalState
    });
  },
  componentDidMount: function(){
    if (this.props.channel){
      this.setGlobalState('channel', this.props.channel);
    }
    var _this = this;
    $.ajax({
      method: 'GET',
      url: `/kb/init.json`,
      success: (function(data){
        document.title = data.config.system_name;
        _this.setGlobalState('config', data.config);
        _this.setGlobalState('user', data.universal_user);
        _this.setGlobalState('users', data.users);
        _this.setGlobalState('subscriber', data.subscriber);
      })
    });
  },
  setGlobalState: function(key, value){
    var globalState = this.state.gs;
    globalState[key] = value;
    this.setState({gs: globalState});
  },
  render: function(){
    return(
      <MessageList
        gs={this.state.gs}
        sgs={this.setGlobalState}
        scopeId={this.props.scope_id}
        new_placeholder={this.props.new_placeholder}
        display_tags={this.props.display_tags}
        new_comment_placeholder={this.props.new_comment_placeholder}
        post_new_content={this.props.post_new_content}
        />
    );
  },
  subscribeChannelButton: function(){
    if (can(this.state.gs, 'subscribe_to_channels')){
      if (this.state.gs.subscriber){
        if (this.state.gs.subscriber.subscribed_to_channels.indexOf(this.state.gs.channel)>-1){
          return(<i className="fa fa-fw fa-bell text-danger" onClick={this.subscribeToChannel} data-subscribe="0" style={{cursor: 'pointer'}} title="Do not notify me of updates" />);
        }else{
          return(<i className="fa fa-fw fa-bell-o" onClick={this.subscribeToChannel} data-subscribe="1" style={{cursor: 'pointer'}} title="Notify me of updates" />);
        }
      }
    }
  },
  subscriberSettings: function(){
    var modal = ReactDOM.findDOMNode(this.refs.edit_subscriber_modal);
    if (modal){
      $(modal).modal('show', {backdrop: 'static'});
    }
  },
  subscribeToChannel: function(e){
    if (!this.state.gs.subscriber.phone_number){
      this.subscriberSettings();
    }else{
      var _this=this;
      var subscribe = $(e.target).attr('data-subscribe')
      $.ajax({
        type: 'PATCH',
        url: `/kb/${this.state.gs.channel}/subscribe`,
        data: {subscribe: subscribe},
        success: function(data){
          _this.setGlobalState('subscriber', data)
        }
      });
    }
  },
  editChannelButton: function(){
    if (can(this.state.gs, 'edit_channels')){
      return(<i className="fa fa-fw fa-pencil small" onClick={this.displayEditChannel} style={{cursor: 'pointer'}} />);
    }
  },
  displayEditChannel: function(){
    var modal = ReactDOM.findDOMNode(this.refs.edit_channel_modal);
    if (modal){
      $(modal).modal('show', {backdrop: 'static'});
    }
  },
  channelNotes: function(){
    if (this.state.gs.channel_notes){
      return(<div className="small text-info">{this.state.gs.channel_notes}</div>);
    }else{
      return(null);
    }
  }
});