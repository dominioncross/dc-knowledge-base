/*global React*/
/*global ReactDOM*/
/*global $*/
var Comment = createReactClass({
  render: function(){
    return(
      <div className="well well-sm">
        {this.content()}
        <RelatedContent relatedContent={this.props.comment.related_content} />
        <div className="text-right text-muted small"><small>{this.props.comment.author} - {this.props.comment.when_formatted}</small></div>
      </div>
    );
  },
  content: function(){
    return(<p style={{marginBottom: '10px'}} dangerouslySetInnerHTML={{__html: Autolinker.link(this.props.comment.content.replace(/(?:\r\n|\r|\n)/g, '<br />'))}} />);
  }
});