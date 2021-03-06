/*
  global React
  global $
*/
var Labels = createReactClass({
  getInitialState: function(){
    return({
      labels: null,
      selectedLabels: []
    });
  },
  componentDidMount: function(){
    if (this.props.gs && this.props.gs.config && this.props.gs.config.labels && this.props.type){
      this.setState({labels: this.props.gs.config.labels[this.props.type], selectedLabels: this.props.labels});
    }
  },
  render: function(){
    if (this.state.labels && this.state.labels.length>0){
      var btns = [];
      for (var i=0;i<this.state.labels.length;i++){
        var label = this.state.labels[i];
        var btn = [];
        btn.push(<button key={`add_${label}`} className={this.labelButtonClass(label)} onClick={this.addLabel} name={`add_${label}`} style={{marginLeft: '3px'}}>{label}</button>);
        btns.push(btn);
      }
      return(
        <div>
          {btns}
        </div>
      );
    }else{
      return(null);
    }
  },
  removeLabel: function(e){
    var label = e.target.name.replace('remove_','');
    this.toggleLabel(label);
  },
  addLabel: function(e){
    var label = e.target.name.replace('add_','');
    this.toggleLabel(label);
  },
  labelButtonClass: function(label){
    return `btn btn-xs${this.labeled(label) ? ' btn-info' : ''}`;
  },
  labeled: function(label){
    return this.state.selectedLabels.indexOf(label.toString())>-1;
  },
  toggleLabel: function(f){
    var _this=this;
    $.ajax({
      method: 'POST',
      url: `/kb/flags/toggle?subject_type=${this.props.subjectType}&subject_id=${this.props.subjectId}&flag=${f}`,
      success: function(data){
        _this.setState({selectedLabels: data.flags});
      }
    });
  },
});