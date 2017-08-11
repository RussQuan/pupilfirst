class FounderDashboardTargets extends React.Component {
  constructor(props) {
    super(props);

    this.state = {
      chosenLevel: props.currentLevel
    };

    this.pickFilter = this.pickFilter.bind(this);
  }

  targetGroups() {
    return this.props.levels[this.state.chosenLevel].target_groups;
  }

  targetCollections() {
    let collectionLength = this.targetGroups().length;

    return this.targetGroups().map(function (targetGroup, targetGroupIndex) {
      let finalCollection = collectionLength === targetGroupIndex + 1;

      return <FounderDashboardTargetCollection key={targetGroup.id} name={targetGroup.name}
        description={targetGroup.description} targets={targetGroup.targets} milestone={targetGroup.milestone}
        finalCollection={finalCollection} iconPaths={this.props.iconPaths} founderDetails={this.props.founderDetails}
        selectTargetCB={this.props.selectTargetCB}/>
    }, this);
  }

  filterData() {
    return {
      levels: this.props.programLevels,
      chosenLevel: this.state.chosenLevel
    };
  }

  pickFilter(level) {
    this.setState({chosenLevel: level});
  }

  render() {
    return (
      <div>
        {this.props.levelUpEligibility !== 'not_eligible' &&
        <FounderDashboardLevelUpNotification authenticityToken={this.props.authenticityToken}
          levelUpEligibility={this.props.levelUpEligibility} currentLevel={this.props.currentLevel}
          maxLevelNumber={this.props.maxLevelNumber}/>
        }

        {this.props.currentLevel !== 0 &&
        <FounderDashboardActionBar filter='targets' filterData={this.filterData()} pickFilterCB={this.pickFilter}
          openTimelineBuilderCB={this.props.openTimelineBuilderCB} currentLevel={this.props.currentLevel}/>
        }

        {this.targetCollections()}
      </div>
    );
  }
}

FounderDashboardTargets.propTypes = {
  currentLevel: React.PropTypes.number,
  levels: React.PropTypes.object,
  openTimelineBuilderCB: React.PropTypes.func,
  levelUpEligibility: React.PropTypes.string,
  authenticityToken: React.PropTypes.string,
  iconPaths: React.PropTypes.object,
  founderDetails: React.PropTypes.array,
  maxLevelNumber: React.PropTypes.number,
  programLevels: React.PropTypes.object,
  selectTargetCB: React.PropTypes.func
};
