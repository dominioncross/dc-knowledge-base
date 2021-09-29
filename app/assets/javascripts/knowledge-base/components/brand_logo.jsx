/*global React*/
var BrandLogo = createReactClass({
  render: function(){
    return(
      <div className="brand">
        <a href="/kb" className="logo">
          <i className="fa fa-question-circle" style={{marginRight: '5px'}}/>
          <span>{this.props.system_name == null ? 'Knowledge Base' : this.props.system_name}</span>
        </a>
      </div>
    );
  }
});