/*global React*/
/*global ReactDOM*/
/*global $*/
var RelatedContent = createReactClass({
  buildContent: function(){
    if (this.props.relatedContent.length>0){
      var a = [];
      this.props.relatedContent.forEach(function(content){
        if (content.type == 'youtube'){
          a.push(
            <li key={`${content.type}_${content.content}`}>
              <a href={`https://www.youtube.com/watch?v=${content.content}`} target="_blank">
                <img src={`https://i.ytimg.com/vi/${content.content}/hqdefault.jpg`} style={{width: '150px'}} data-url={content.content} />
              </a>
            </li>
          );
        }
      });
      return(
        <ul className="list list-inline">
          {a}
        </ul>
      );
    }else{
      return null;
    }
  },
  render: function(){
    return(
      this.buildContent()
    );
  }
});